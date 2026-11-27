-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- L1: distinguish the date of a research snapshot from the milestone dates it describes.

SELECT project_id, record_id, description,
       exact_date AS snapshot_date, date_meaning, record_status,
       qualification, source_id, source_url
FROM analytics.project_timeline
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
  AND record_type = 'observation'
ORDER BY project_id, exact_date, record_id;

SELECT project_id, claim_id, research_statement, measurement_status,
       evidence_status, source_id, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F03'), ('PRJ001', 'F06'), ('PRJ001', 'F07'), ('PRJ001', 'F09'),
    ('PRJ002', 'F17'), ('PRJ002', 'F18'), ('PRJ002', 'F19'), ('PRJ002', 'F23'),
    ('PRJ003', 'F25'), ('PRJ003', 'F28'), ('PRJ003', 'F29'), ('PRJ003', 'F30')
)
ORDER BY project_id, claim_id;
