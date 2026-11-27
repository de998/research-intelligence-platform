-- Run in DBeaver against the local Research Intelligence PostgreSQL database (research_demo).
-- F1: investment, procurement, project scope, and cost evidence.

SELECT project_id, claim_id, claim_type, research_statement,
       reported_numeric_value, unit_standardized, measurement_status,
       evidence_status, review_status, source_id, source_published_date, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F03'), ('PRJ001', 'F06'), ('PRJ001', 'F08'),
    ('PRJ001', 'F10'), ('PRJ001', 'F11'), ('PRJ001', 'F12'), ('PRJ001', 'F13'),
    ('PRJ002', 'F14'), ('PRJ002', 'F15'), ('PRJ002', 'F16'), ('PRJ002', 'F20'),
    ('PRJ003', 'F25'), ('PRJ003', 'F26'), ('PRJ003', 'F27'), ('PRJ003', 'F31')
)
ORDER BY project_id, claim_id;

SELECT project_id, metric_id, claim_id, metric_description, metric_value,
       unit_standardized, measurement_status, evidence_status, source_id, source_url
FROM analytics.project_metrics
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
  AND unit_standardized ILIKE 'CNY%'
ORDER BY project_id, metric_id;
