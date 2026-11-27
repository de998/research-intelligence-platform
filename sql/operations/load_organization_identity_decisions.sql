
\set ON_ERROR_STOP on

BEGIN;

CREATE TEMP TABLE incoming_identity_decisions (
    alias_org_id TEXT,
    canonical_org_id TEXT,
    decision_status TEXT,
    evidence_source_id TEXT,
    reviewed_by TEXT,
    reviewed_at TEXT,
    resolution_note TEXT
) ON COMMIT DROP;

\copy incoming_identity_decisions (alias_org_id, canonical_org_id, decision_status, evidence_source_id, reviewed_by, reviewed_at, resolution_note) FROM 'inputs/organization_identity_decisions.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

INSERT INTO raw.raw_organization_identity_decisions (
    alias_org_id,
    canonical_org_id,
    decision_status,
    evidence_source_id,
    reviewed_by,
    reviewed_at,
    resolution_note
)
SELECT
    alias_org_id,
    canonical_org_id,
    decision_status,
    evidence_source_id,
    reviewed_by,
    reviewed_at,
    resolution_note
FROM incoming_identity_decisions

ON CONFLICT (alias_org_id)
DO UPDATE SET
    canonical_org_id = EXCLUDED.canonical_org_id,
    decision_status = EXCLUDED.decision_status,
    evidence_source_id = EXCLUDED.evidence_source_id,
    reviewed_by = EXCLUDED.reviewed_by,
    reviewed_at = EXCLUDED.reviewed_at,
    resolution_note = EXCLUDED.resolution_note;

COMMIT;
