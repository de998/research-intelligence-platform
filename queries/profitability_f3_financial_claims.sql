-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- F3: inspect financial claims, monetary metrics, and named project organizations.

SELECT project_id, claim_id, claim_type, research_statement, reported_numeric_value,
       unit_standardized, measurement_status, evidence_status, review_status,
       source_id, source_url
FROM analytics.claim_evidence
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
  AND (
    claim_type IN ('investment_plan', 'procurement', 'contract_scope', 'cost_estimate')
    OR research_statement ~* '(payroll|payout|remunerat|salary|paid|payment|disburs|cash.flow|NPV|present value|fund|revenue|settle|expenditure)'
  )
ORDER BY project_id, claim_id;

SELECT project_id, metric_id, claim_id, metric_description, metric_value,
       unit_standardized, measurement_status, source_id, source_url
FROM analytics.project_metrics
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
  AND unit_standardized ILIKE 'CNY%'
ORDER BY project_id, metric_id;

SELECT project_id, mention_id, organization_name, reported_role,
       relationship_evidence_status, source_id, source_url
FROM analytics.organization_involvement
WHERE mention_id IN ('R003', 'R004', 'R005', 'R007', 'R009', 'R011', 'R012')
ORDER BY project_id, mention_id;
