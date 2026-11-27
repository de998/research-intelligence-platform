-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- L3: compare asset dependencies, maintenance commitments, and reported concerns.
-- The status columns distinguish documented scope from hypotheses and industry signals.

SELECT project_id, claim_id, research_statement, measurement_status,
       evidence_status, source_id, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F06'), ('PRJ001', 'F13'),
    ('PRJ002', 'F19'), ('PRJ002', 'F20'), ('PRJ002', 'F21'), ('PRJ002', 'F22'),
    ('PRJ003', 'F25'), ('PRJ003', 'F28'), ('PRJ003', 'F29'), ('PRJ003', 'F36')
)
ORDER BY project_id, claim_id;

SELECT project_id, record_id, research_item, evidence_status,
       client_validation_required, source_ids, source_urls
FROM analytics.commercial_research
WHERE (project_id, record_id) IN (
    ('PRJ001', 'PP02'), ('PRJ001', 'PP03'),
    ('PRJ002', 'PP05'), ('PRJ002', 'PP06'),
    ('PRJ003', 'PP08'), ('PRJ003', 'PP09'), ('PRJ003', 'PP10')
)
ORDER BY project_id, record_id;
