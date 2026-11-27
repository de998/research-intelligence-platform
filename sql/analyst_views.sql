-- Analyst-facing views. The build runs this file inside its analytics transaction.
-- Project-scoped datasets share project_id; all joins retain their natural row grain.

CREATE OR REPLACE VIEW analytics.projects AS
SELECT p.project_id, p.project_name_en AS project_name, p.project_name_zh,
       p.industry, p.location, v.reported_stage, v.stage_as_of_date,
       v.stage_qualification, v.claim_count, v.metric_count, v.pain_point_count,
       v.opportunity_count, v.stage_source_id, v.source_url AS stage_source_url
FROM core.projects AS p
LEFT JOIN analytics.project_overview AS v USING (project_id);

CREATE OR REPLACE VIEW analytics.sources AS
SELECT source_id, title, publisher, source_type, url AS source_url,
       published_date_exact AS published_date, published_date_precision,
       published_date_raw AS published_date_as_reported,
       accessed_date_exact AS accessed_date, research_project_id AS catalog_project_id,
       source_lineage, verification_note, full_text_stored
FROM core.sources;

CREATE OR REPLACE VIEW analytics.claims AS
SELECT project_id, claim_id, claim_type, research_statement AS claim,
       evidence_status, review_status, measurement_status,
       reported_numeric_value AS value, unit_standardized AS unit,
       source_id, publisher AS source_publisher, source_published_date,
       research_accessed_date AS accessed_date, source_url
FROM analytics.claim_evidence;

CREATE OR REPLACE VIEW analytics.metrics AS
SELECT project_id, metric_id, claim_id, metric_type, metric_description AS metric,
       metric_value AS value, unit_standardized AS unit, measurement_status,
       evidence_status, review_status, source_id, source_published_date, source_url
FROM analytics.project_metrics;

CREATE OR REPLACE VIEW analytics.timeline AS
SELECT project_id, record_id AS timeline_id, record_type AS timeline_type,
       description, exact_date AS timeline_date, date_meaning AS date_kind,
       date_as_reported, date_precision, record_status, qualification,
       source_id, source_url
FROM analytics.project_timeline;

CREATE OR REPLACE VIEW analytics.organizations AS
SELECT org_id AS organization_id, organization_name
FROM core.organizations;

-- Reported mentions and reviewed decisions have different sources and statuses.
CREATE OR REPLACE VIEW analytics.project_roles AS
SELECT project_id, org_id AS organization_id, organization_name,
       'reported_mention'::text AS role_basis, mention_id AS role_record_id,
       reported_role AS role, relationship_evidence_status AS evidence_status,
       NULL::text AS decision_status, NULL::date AS status_effective_on,
       NULL::date AS reviewed_on, source_id, source_url
FROM analytics.organization_involvement
UNION ALL
SELECT r.project_id, r.org_id, o.organization_name,
       'reviewed_decision', r.latest_decision_id, r.role_type, NULL,
       r.current_status, r.status_effective_on, r.reviewed_on,
       r.evidence_source_id, s.url
FROM core.project_organizations AS r
LEFT JOIN core.organizations AS o USING (org_id)
LEFT JOIN core.sources AS s ON s.source_id = r.evidence_source_id;

CREATE OR REPLACE VIEW analytics.project_networks AS
SELECT p.project_id, p.network_id, n.network_name_en AS network_name, n.network_name_zh,
       p.relevance_type, p.classification_status, p.classification_rationale,
       p.reviewed_at AS reviewed_at_as_recorded, p.source_id, s.url AS source_url
FROM core.project_networks AS p
LEFT JOIN core.networks AS n USING (network_id)
LEFT JOIN core.sources AS s USING (source_id);

CREATE OR REPLACE VIEW analytics.pain_points AS
SELECT project_id, pain_point_id, pain_point_description AS pain_point, category,
       evidence_classification AS evidence_status,
       why_classified_this_way AS evidence_note,
       requires_client_validation AS client_validation_required,
       accessed_date_exact AS accessed_date, source_id, source_url
FROM core.pain_points;

CREATE OR REPLACE VIEW analytics.opportunities AS
SELECT project_id, record_id AS opportunity_id, research_item AS proposed_service,
       evidence_status, client_budget_known, client_purchase_intent_known,
       research_note AS proposed_follow_up, human_assessment AS assessment_outcome,
       human_score_out_of_20 AS assessment_score_out_of_20,
       human_analysis AS assessment_note, source_ids, source_urls
FROM analytics.commercial_research
WHERE record_type = 'opportunity';

CREATE OR REPLACE VIEW analytics.opportunity_sources AS
SELECT DISTINCT project_id, opportunity_id, source_id, publisher AS source_publisher,
       source_url, evidence_link_status
FROM core.opportunity_source_basis;

CREATE OR REPLACE VIEW analytics.opportunity_pain_points AS
SELECT project_id, pain_point_id, opportunity_id, pain_point_description AS pain_point,
       potential_service AS proposed_service, rationale AS decision_rationale,
       decided_on AS decision_date, decision_id, evidence_source_id AS source_id,
       evidence_source_url AS source_url
FROM core.phase7_approved_relationships;

CREATE OR REPLACE VIEW analytics.review_queue AS
SELECT project_id, record_type, record_id, research_item AS item,
       review_reason, evidence_status, source_urls
FROM analytics.research_gaps;

CREATE OR REPLACE VIEW analytics.start_here AS
SELECT position, topic, view_name, row_grain, use_for, join_keys, example_sql
FROM (VALUES
    (10, 'Projects', 'projects', 'One project',
     'Find projects and their latest recorded stage snapshots.', 'project_id',
     'SELECT project_id, project_name, reported_stage, stage_as_of_date FROM analytics.projects ORDER BY project_id;'),
    (20, 'Evidence', 'claims', 'One recorded claim',
     'Read reported statements, their evidence status and original sources.', 'project_id, claim_id, source_id',
     'SELECT claim_id, claim, evidence_status, source_url FROM analytics.claims WHERE project_id = ''PRJ001'';'),
    (30, 'Evidence', 'metrics', 'One numeric metric from a claim',
     'Compare figures with their units and measurement status.', 'project_id, claim_id, source_id',
     'SELECT project_id, metric, value, unit, measurement_status FROM analytics.metrics WHERE unit LIKE ''CNY%'';'),
    (40, 'Evidence', 'sources', 'One registered source',
     'Look up a source by ID and check publication precision or verification notes.', 'source_id',
     'SELECT source_id, publisher, title, source_url FROM analytics.sources WHERE catalog_project_id = ''PRJ002'';'),
    (50, 'Timeline', 'timeline', 'One observation, reported event or forecast',
     'Compare milestones and use date_kind to tell targets, events and snapshots apart.', 'project_id, source_id',
     'SELECT project_id, timeline_type, description, date_kind, date_as_reported FROM analytics.timeline ORDER BY project_id, timeline_date DESC NULLS LAST;'),
    (60, 'Organizations and networks', 'project_roles', 'One source mention or latest reviewed decision for a project, organization and role',
     'Find participants and use role_basis to distinguish reported roles from reviewed decisions.', 'project_id, organization_id, source_id',
     'SELECT organization_name, role, role_basis, decision_status FROM analytics.project_roles WHERE project_id = ''PRJ002'';'),
    (70, 'Organizations and networks', 'organizations', 'One organization ID in the organization register',
     'Look up organization names and IDs before finding their project roles.', 'organization_id',
     'SELECT organization_id, organization_name FROM analytics.organizations ORDER BY organization_name;'),
    (80, 'Organizations and networks', 'project_networks', 'One recorded project and network classification',
     'See each recorded network classification, its status and rationale.', 'project_id, network_id, source_id',
     'SELECT project_id, network_name, relevance_type, classification_status FROM analytics.project_networks ORDER BY project_id, network_id;'),
    (90, 'Commercial', 'pain_points', 'One recorded pain point',
     'Compare documented issues and hypotheses using evidence_status.', 'project_id, pain_point_id, source_id',
     'SELECT project_id, category, pain_point, evidence_status FROM analytics.pain_points ORDER BY project_id, pain_point_id;'),
    (100, 'Commercial', 'opportunities', 'One opportunity with its current assessment when recorded',
     'Review proposed services, validation steps, and what is known about buyer budget or intent.', 'project_id, opportunity_id',
     'SELECT project_id, proposed_service, evidence_status, proposed_follow_up FROM analytics.opportunities;'),
    (110, 'Commercial', 'opportunity_sources', 'One referenced source per opportunity',
     'Trace opportunity sources individually and check the evidence link status.', 'project_id, opportunity_id, source_id',
     'SELECT opportunity_id, source_id, evidence_link_status, source_url FROM analytics.opportunity_sources;'),
    (115, 'Commercial', 'opportunity_pain_points', 'One currently approved pain point and opportunity pair',
     'Find explicitly approved links between problems and services.', 'project_id, pain_point_id, opportunity_id, source_id',
     'SELECT project_id, pain_point, proposed_service, decision_rationale FROM analytics.opportunity_pain_points;'),
    (120, 'Research workflow', 'review_queue', 'One outstanding claim or commercial review item',
     'Find queued reviews for claims, pain points and opportunities.', 'project_id, record_type, record_id',
     'SELECT project_id, record_type, item, review_reason FROM analytics.review_queue ORDER BY project_id, record_type;'),
    (130, 'Research workflow', 'project_evaluation', 'One worksheet question and supporting research record',
     'Run the existing worksheet demo for the three selected projects.', 'project_id, question_id',
     'SELECT project_id, finding, evidence_status, source_urls FROM analytics.project_evaluation WHERE question_id = ''S1'';')
) AS directory(position, topic, view_name, row_grain, use_for, join_keys, example_sql);

COMMENT ON VIEW analytics.start_here IS
    'Analyst directory with row definitions, common join keys and runnable examples. Order by position.';

COMMENT ON VIEW analytics.projects IS 'One project with its most recent recorded stage snapshot and research coverage.';
COMMENT ON VIEW analytics.sources IS 'One registered source with publication precision and verification notes.';
COMMENT ON VIEW analytics.claims IS 'One recorded claim with its evidence, review and measurement statuses.';
COMMENT ON VIEW analytics.metrics IS 'One numeric metric from a claim, with its unit and measurement status.';
COMMENT ON VIEW analytics.timeline IS 'One observation, reported event or forecast. Read date_kind to interpret timeline_date.';
COMMENT ON VIEW analytics.organizations IS 'One organization ID from the organization register.';
COMMENT ON VIEW analytics.project_roles IS 'One source-reported mention or latest reviewed decision for a project, organization and role.';
COMMENT ON VIEW analytics.project_networks IS 'One recorded project and network classification, including rationale and review status.';
COMMENT ON VIEW analytics.pain_points IS 'One recorded pain point. Use evidence_status to distinguish documented issues and hypotheses.';
COMMENT ON VIEW analytics.opportunities IS 'One potential service with available buyer information and current human assessment.';
COMMENT ON VIEW analytics.opportunity_sources IS 'One referenced source per opportunity, with evidence link status.';
COMMENT ON VIEW analytics.opportunity_pain_points IS 'One explicitly approved pain point and opportunity pair within the same project.';
COMMENT ON VIEW analytics.review_queue IS 'One outstanding claim or commercial review item.';

COMMENT ON COLUMN analytics.sources.catalog_project_id IS
    'Project assigned in the source register. Use source_id to trace references from other records.';
COMMENT ON COLUMN analytics.metrics.value IS
    'Compare only figures with compatible units, scope and measurement status. A metric is derived from its matching claim.';
COMMENT ON COLUMN analytics.timeline.timeline_date IS
    'Exact date when available. Read date_kind before treating it as an event date. Partial dates are preserved in date_as_reported.';
COMMENT ON COLUMN analytics.project_roles.role_basis IS
    'reported_mention shows what a source says. reviewed_decision shows the current reviewed status, which may be unapproved or inactive.';
COMMENT ON COLUMN analytics.opportunity_sources.evidence_link_status IS
    'A cited source is a reference to inspect. Its inclusion does not establish that it supports the proposed service.';

COMMENT ON VIEW analytics.catalog IS 'Original catalog. For guided discovery, use analytics.start_here.';
COMMENT ON VIEW analytics.project_overview IS 'Existing project overview. For exploratory work, start with analytics.projects.';
COMMENT ON VIEW analytics.claim_evidence IS 'Existing claim evidence view. For exploratory work, start with analytics.claims.';
COMMENT ON VIEW analytics.project_metrics IS 'Existing metrics view. For exploratory work, start with analytics.metrics.';
COMMENT ON VIEW analytics.project_timeline IS 'Existing timeline view. For exploratory work, start with analytics.timeline.';
COMMENT ON VIEW analytics.organization_involvement IS 'Existing source-reported mentions. See analytics.project_roles for mentions and reviewed roles.';
COMMENT ON VIEW analytics.commercial_research IS 'Existing combined view. For exploratory work, use analytics.pain_points or analytics.opportunities.';
COMMENT ON VIEW analytics.research_gaps IS 'Existing review view. For exploratory work, start with analytics.review_queue.';
