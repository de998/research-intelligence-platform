
\set ON_ERROR_STOP on

BEGIN;

CREATE TEMP TABLE incoming_status_decisions (
    decision_id TEXT PRIMARY KEY,
    mention_id TEXT,
    role_type TEXT,
    relationship_status TEXT,
    effective_on DATE,
    decision_status TEXT,
    reviewed_by TEXT,
    reviewed_on DATE,
    review_note TEXT
) ON COMMIT DROP;

\copy incoming_status_decisions FROM 'inputs/project_org_status_decisions.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM incoming_status_decisions i
        JOIN raw.raw_project_org_status_decisions r
            ON i.decision_id = r.decision_id
        WHERE ROW(
            i.mention_id, i.role_type, i.relationship_status,
            i.effective_on, i.decision_status, i.reviewed_by,
            i.reviewed_on, i.review_note
        ) IS DISTINCT FROM ROW(
            r.mention_id, r.role_type, r.relationship_status,
            r.effective_on, r.decision_status, r.reviewed_by,
            r.reviewed_on, r.review_note
        )
    ) THEN
        RAISE EXCEPTION
            'Existing decision ID has different content. Use a new ID.';
    END IF;
END
$$;

INSERT INTO raw.raw_project_org_status_decisions
SELECT *
FROM incoming_status_decisions
ON CONFLICT (decision_id) DO NOTHING;

COMMIT;
