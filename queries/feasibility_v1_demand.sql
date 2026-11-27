-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- V1: surface design capacity, test results, and demand evidence for the three projects.

SELECT project_id, claim_id, claim_type, research_statement, measurement_status,
       evidence_status, source_id, source_published_date, source_url
FROM analytics.claim_evidence
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
  AND (
    claim_id IN ('F03', 'F04', 'F07', 'F09', 'F16', 'F22', 'F23', 'F24',
                 'F28', 'F29', 'F30')
    OR research_statement ~* '(commitment|paid.*(volum|order)|shipper contract|metered sales|actual throughput|delivery log)'
  )
ORDER BY project_id, claim_id;

SELECT project_id, metric_id, claim_id, metric_description, metric_value,
       unit_standardized, measurement_status, evidence_status, source_id, source_url
FROM analytics.project_metrics
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
  AND claim_id IN ('F03', 'F04', 'F16', 'F22', 'F28', 'F29', 'F30')
ORDER BY project_id, metric_id;

SELECT project_id, record_id, research_item, evidence_status,
       client_validation_required, source_ids, source_urls
FROM analytics.commercial_research
WHERE record_id IN ('PP01', 'PP04', 'PP07', 'PP10')
ORDER BY project_id, record_id;
