-- Research Intelligence three-project decision demo
-- Run one numbered SELECT at a time in DBeaver against the research_demo database.

-- 1. Stability
-- Compare reported approval or oversight evidence and its source status.
SELECT
    project_id,
    claim_id,
    research_statement AS approval_or_oversight_evidence,
    measurement_status,
    evidence_status,
    source_url
FROM analytics.claim_evidence
WHERE claim_id IN ('F09', 'F18', 'F36')
ORDER BY project_id;

-- 2. Profitability
-- Read the metric description and unit before comparing investment and operating cost figures.
SELECT
    project_id,
    metric_description,
    metric_value,
    unit_standardized,
    measurement_status,
    source_url
FROM analytics.project_metrics
WHERE claim_id IN ('F08', 'F15', 'F31')
ORDER BY project_id;

-- 3. Longevity
-- Compare the status snapshots and show any recorded maintenance tender scope.
SELECT
    timeline.project_id,
    timeline.description AS recorded_project_stage,
    timeline.qualification AS stage_qualification,
    timeline.date_as_reported AS snapshot_date_as_reported,
    timeline.source_url AS stage_source_url,
    maintenance.research_statement AS maintenance_tender_scope,
    maintenance.source_url AS maintenance_source_url
FROM analytics.project_timeline AS timeline
LEFT JOIN analytics.claim_evidence AS maintenance
    ON maintenance.project_id = timeline.project_id
    AND maintenance.claim_id = 'F13'
WHERE timeline.record_status = 'research_snapshot'
    AND timeline.project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
ORDER BY timeline.project_id;

-- 4. Feasibility and Viability
-- Compare the type of evidence available for planned capacity and pilot performance.
SELECT
    project_id,
    claim_id,
    metric_description,
    metric_value,
    unit_standardized,
    measurement_status,
    source_url
FROM analytics.project_metrics
WHERE claim_id IN ('F04', 'F22', 'F28', 'F29')
ORDER BY project_id, claim_id;

-- 5. Research Intelligence Opportunities
-- Show the proposed services, their evidence status, and what buyer information is known.
SELECT
    project_id,
    record_id,
    research_item AS proposed_service,
    evidence_status,
    client_budget_known,
    client_purchase_intent_known,
    research_note AS next_validation_step,
    source_urls
FROM analytics.commercial_research
WHERE record_id IN ('HYP001', 'HYP002', 'HYP003')
ORDER BY project_id;
