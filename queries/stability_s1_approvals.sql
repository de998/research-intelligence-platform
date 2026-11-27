-- Run in DBeaver against Research Intelligence PostgreSQL (research_demo).
-- Compare stored milestone, acceptance and approval evidence for S1.
SELECT
    project_id, claim_id, research_statement, measurement_status,
    evidence_status, review_status, source_id, source_published_date, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F07'), ('PRJ001', 'F09'),
    ('PRJ002', 'F18'), ('PRJ002', 'F19'), ('PRJ002', 'F23'),
    ('PRJ003', 'F28'), ('PRJ003', 'F36')
)
ORDER BY project_id, claim_id;
