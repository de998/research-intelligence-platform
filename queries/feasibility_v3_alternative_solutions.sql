-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- V3: retrieve the factual baseline for evaluating staged openings and operating tests.

SELECT project_id, record_id, description, exact_date AS snapshot_date,
       date_meaning, record_status, qualification, source_id, source_url
FROM analytics.project_timeline
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
  AND record_type = 'observation'
ORDER BY project_id, exact_date, record_id;

SELECT project_id, claim_id, research_statement, reported_numeric_value,
       unit_standardized, measurement_status, evidence_status,
       source_id, source_published_date, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F03'), ('PRJ001', 'F06'), ('PRJ001', 'F07'), ('PRJ001', 'F13'),
    ('PRJ002', 'F18'), ('PRJ002', 'F19'), ('PRJ002', 'F22'), ('PRJ002', 'F23'),
    ('PRJ003', 'F28'), ('PRJ003', 'F29'), ('PRJ003', 'F30'), ('PRJ003', 'F36')
)
ORDER BY project_id, claim_id;
