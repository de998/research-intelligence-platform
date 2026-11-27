
\set ON_ERROR_STOP on

BEGIN;

-- 1. Temporary raw inputs

CREATE TEMP TABLE phase3f_identity_input (
    alias_org_id TEXT,
    canonical_org_id TEXT,
    decision_status TEXT,
    evidence_source_id TEXT,
    reviewed_by TEXT,
    reviewed_at TEXT,
    resolution_note TEXT
);

CREATE TEMP TABLE phase3f_status_input (
    decision_id TEXT,
    mention_id TEXT,
    role_type TEXT,
    relationship_status TEXT,
    effective_on DATE,
    decision_status TEXT,
    reviewed_by TEXT,
    reviewed_on DATE,
    review_note TEXT
);

\copy phase3f_identity_input FROM 'inputs/phase3f_identity_test.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

\copy phase3f_status_input FROM 'inputs/phase3f_status_test.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

-- 2. Clean the incoming records

CREATE TEMP VIEW phase3f_clean_identity AS
SELECT
    NULLIF(UPPER(BTRIM(alias_org_id)), '') AS alias_org_id,
    NULLIF(UPPER(BTRIM(canonical_org_id)), '') AS canonical_org_id,
    LOWER(BTRIM(decision_status)) AS decision_status,
    NULLIF(BTRIM(evidence_source_id), '') AS evidence_source_id,
    NULLIF(BTRIM(reviewed_by), '') AS reviewed_by,
    NULLIF(BTRIM(reviewed_at), '') AS reviewed_at
FROM phase3f_identity_input;

CREATE TEMP VIEW phase3f_clean_status AS
SELECT
    UPPER(BTRIM(decision_id)) AS decision_id,
    UPPER(BTRIM(mention_id)) AS mention_id,
    LOWER(BTRIM(role_type)) AS role_type,
    LOWER(BTRIM(relationship_status)) AS relationship_status,
    effective_on,
    LOWER(BTRIM(decision_status)) AS decision_status,
    NULLIF(BTRIM(reviewed_by), '') AS reviewed_by,
    reviewed_on
FROM phase3f_status_input;

-- 3. Simulate one source-backed organization mention

CREATE TEMP VIEW phase3f_mentions AS
SELECT
    'TEST_M1'::TEXT AS mention_id,
    'TEST_P1'::TEXT AS project_id,
    'TEST_O99'::TEXT AS reported_org_id,
    'TEST_S1'::TEXT AS source_id;

-- 4. Resolve the verified organization alias

CREATE TEMP VIEW phase3f_resolved AS
SELECT
    m.*,
    COALESCE(a.canonical_org_id, m.reported_org_id)
        AS canonical_org_id
FROM phase3f_mentions m
LEFT JOIN phase3f_clean_identity a
    ON m.reported_org_id = a.alias_org_id
   AND a.decision_status = 'verified'
   AND a.evidence_source_id IS NOT NULL
   AND a.reviewed_by IS NOT NULL
   AND a.reviewed_at IS NOT NULL;

-- 5. Keep accepted events in history

CREATE TEMP VIEW phase3f_history AS
SELECT
    d.decision_id,
    m.project_id,
    m.reported_org_id,
    m.canonical_org_id,
    d.role_type,
    d.relationship_status,
    d.effective_on,
    d.reviewed_on
FROM phase3f_clean_status d
JOIN phase3f_resolved m
    ON d.mention_id = m.mention_id
WHERE d.decision_status = 'verified'
  AND d.effective_on IS NOT NULL
  AND d.reviewed_by IS NOT NULL
  AND d.reviewed_on IS NOT NULL;

-- 6. Automatically determine current status

CREATE TEMP VIEW phase3f_current AS
SELECT
    project_id,
    canonical_org_id,
    role_type,
    relationship_status AS current_status,
    decision_id AS latest_decision_id
FROM (
    SELECT
        h.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                project_id,
                canonical_org_id,
                role_type
            ORDER BY
                effective_on DESC,
                reviewed_on DESC,
                decision_id DESC
        ) AS status_rank
    FROM phase3f_history h
    WHERE effective_on <=
        (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Shanghai')::DATE
      AND reviewed_on <=
        (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Shanghai')::DATE
) ranked
WHERE status_rank = 1;

-- 7. Automatically fail if results are incorrect

DO $$
BEGIN
    IF (SELECT COUNT(*) FROM phase3f_identity_input) <> 1 THEN
        RAISE EXCEPTION 'Identity import count incorrect';
    END IF;

    IF (SELECT COUNT(*) FROM phase3f_status_input) <> 4 THEN
        RAISE EXCEPTION 'Status import count incorrect';
    END IF;

    IF (SELECT canonical_org_id FROM phase3f_resolved)
       IS DISTINCT FROM 'TEST_O01' THEN
        RAISE EXCEPTION 'Identity resolution failed';
    END IF;

    IF (SELECT COUNT(*) FROM phase3f_history) <> 3 THEN
        RAISE EXCEPTION 'Accepted history count incorrect';
    END IF;

    IF EXISTS (
        SELECT 1 FROM phase3f_history
        WHERE decision_id = 'TEST_D3'
    ) THEN
        RAISE EXCEPTION 'Unverified event was accepted';
    END IF;

    IF (SELECT COUNT(*) FROM phase3f_current) <> 1 THEN
        RAISE EXCEPTION 'Current relationship count incorrect';
    END IF;

    IF (SELECT latest_decision_id FROM phase3f_current)
       IS DISTINCT FROM 'TEST_D2' THEN
        RAISE EXCEPTION 'Latest status selection failed';
    END IF;
END
$$;

-- 8. Display results

SELECT
    h.decision_id,
    h.reported_org_id,
    h.canonical_org_id,
    h.relationship_status,
    h.effective_on,
    CASE
        WHEN h.decision_id = c.latest_decision_id
            THEN 'CURRENT'
        WHEN h.effective_on >
             (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Shanghai')::DATE
            THEN 'FUTURE'
        ELSE 'HISTORICAL'
    END AS record_position
FROM phase3f_history h
LEFT JOIN phase3f_current c
    ON h.project_id = c.project_id
   AND h.canonical_org_id = c.canonical_org_id
   AND h.role_type = c.role_type
ORDER BY h.effective_on;

-- 9. Discard all test objects

ROLLBACK;
