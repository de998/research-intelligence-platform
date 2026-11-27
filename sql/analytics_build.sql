
\set ON_ERROR_STOP on

BEGIN;

CREATE SCHEMA IF NOT EXISTS analytics;

-- ==================================================
-- 1. PROJECT OVERVIEW
-- One row per project
-- ==================================================

CREATE OR REPLACE VIEW analytics.project_overview AS

WITH latest_observation AS (
    SELECT
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY o.project_id
            ORDER BY
                o.observation_as_of_date DESC,
                o.imported_at DESC,
                o.observation_id DESC
        ) AS rn
    FROM core.project_observations o
),

claim_counts AS (
    SELECT project_id, COUNT(*) AS claim_count
    FROM core.claims
    GROUP BY project_id
),

metric_counts AS (
    SELECT project_id, COUNT(*) AS metric_count
    FROM core.project_metrics
    GROUP BY project_id
)

SELECT
    p.project_id,
    p.project_name_en AS project_name,
    p.industry,
    p.location,

    o.observed_project_stage AS reported_stage,
    o.observation_as_of_date AS stage_as_of_date,
    o.review_note AS stage_qualification,

    COALESCE(c.claim_count, 0) AS claim_count,
    COALESCE(m.metric_count, 0) AS metric_count,

    p.pain_point_count,
    p.opportunity_count,
    p.current_assessment_count,
    p.approved_relationship_count,

    o.source_id AS stage_source_id,
    COALESCE(o.source_url, s.url) AS source_url

FROM core.phase7_project_summary p

LEFT JOIN latest_observation o
    ON p.project_id = o.project_id
   AND o.rn = 1

LEFT JOIN core.sources s
    ON o.source_id = s.source_id

LEFT JOIN claim_counts c
    ON p.project_id = c.project_id

LEFT JOIN metric_counts m
    ON p.project_id = m.project_id;


-- ==================================================
-- 2. CLAIM EVIDENCE
-- One row per research claim
-- ==================================================

CREATE OR REPLACE VIEW analytics.claim_evidence AS

SELECT
    c.claim_id,
    c.project_id,

    c.extracted_statement_en AS research_statement,
    c.claim_type,

    c.reported_numeric_value,
    c.unit_standardized,

    c.measurement_status,
    c.evidence_status,
    c.review_status,

    c.source_id,
    s.publisher,

    s.published_date_exact AS source_published_date,
    c.accessed_date_exact AS research_accessed_date,

    COALESCE(
        NULLIF(BTRIM(c.source_url), ''),
        s.url
    ) AS source_url

FROM core.claims c

LEFT JOIN core.sources s
    ON c.source_id = s.source_id;


-- ==================================================
-- 3. PROJECT METRICS
-- One row per numerical research metric
-- ==================================================

CREATE OR REPLACE VIEW analytics.project_metrics AS

SELECT
    m.metric_id,
    m.claim_id,
    m.project_id,

    m.metric_type,
    m.metric_description,

    m.metric_value,
    m.unit_standardized,

    m.measurement_status,
    m.evidence_status,
    m.review_status,

    m.source_published_date,
    m.source_id,

    COALESCE(
        NULLIF(BTRIM(m.claim_source_url), ''),
        m.source_catalog_url
    ) AS source_url

FROM core.project_metrics m;


-- ==================================================
-- 4. ORGANIZATION INVOLVEMENT
-- One row per source-reported organization mention
-- ==================================================

CREATE OR REPLACE VIEW
analytics.organization_involvement AS

SELECT
    m.mention_id,
    m.project_id,

    m.org_id,
    o.organization_name,

    m.role_as_reported AS reported_role,
    m.relationship_evidence_status,

    m.source_id,
    s.publisher,

    COALESCE(
        NULLIF(BTRIM(m.source_url), ''),
        s.url
    ) AS source_url

FROM core.org_mentions m

LEFT JOIN core.organizations o
    ON m.org_id = o.org_id

LEFT JOIN core.sources s
    ON m.source_id = s.source_id;


-- ==================================================
-- 5. PROJECT TIMELINE
-- Observations, reviewed events and forecasts
-- Each record type is explicitly distinguished
-- ==================================================

CREATE OR REPLACE VIEW analytics.project_timeline AS

SELECT
    o.project_id,

    'observation'::TEXT AS record_type,
    o.observation_id AS record_id,

    o.observed_project_stage AS description,

    'research_as_of_date'::TEXT AS date_meaning,
    o.observation_as_of_date AS exact_date,
    'day'::TEXT AS date_precision,

    o.observation_as_of_date::TEXT AS date_as_reported,

    'research_snapshot'::TEXT AS record_status,

    o.review_note AS qualification,

    o.source_id,
    o.source_url

FROM core.project_observations o

UNION ALL

SELECT
    e.project_id,

    'reported_event'::TEXT,
    e.event_id,

    e.event_description,

    'event_occurrence_date'::TEXT,
    e.event_date_exact,
    e.event_date_precision,

    COALESCE(
        NULLIF(BTRIM(e.event_date_raw), ''),
        e.event_date_exact::TEXT
    ),

    'reviewed_event_report'::TEXT,

    NULL::TEXT,

    e.source_id,
    e.source_url

FROM core.project_events e

UNION ALL

SELECT
    f.project_id,

    'forecast'::TEXT,
    f.forecast_id,

    f.forecast_statement,

    'forecast_target_date'::TEXT,
    f.target_date_exact,
    f.target_date_precision,

    COALESCE(
        NULLIF(BTRIM(f.target_date_raw), ''),
        CASE
            WHEN f.target_date_precision = 'day'
                THEN f.target_date_exact::TEXT
            WHEN f.target_date_precision = 'month'
                THEN f.target_year::TEXT || '-' ||
                     LPAD(f.target_month::TEXT, 2, '0')
            WHEN f.target_date_precision = 'year'
                THEN f.target_year::TEXT
            ELSE NULL
        END
    ),

    'reviewed_forecast_statement'::TEXT,

    NULL::TEXT,

    f.source_id,
    f.source_url

FROM core.event_forecasts f;


-- ==================================================
-- 6. COMMERCIAL RESEARCH
-- Pain points and opportunities kept distinct
-- One row per pain point or opportunity
-- ==================================================

CREATE OR REPLACE VIEW analytics.commercial_research AS

WITH opportunity_links AS (
    SELECT
        opportunity_id,

        STRING_AGG(
            source_id, ';' ORDER BY source_id
        ) AS source_ids,

        STRING_AGG(
            source_url, E'\n' ORDER BY source_id
        ) FILTER (
            WHERE source_url IS NOT NULL
        ) AS source_urls

    FROM core.opportunity_source_basis
    GROUP BY opportunity_id
)

SELECT
    p.project_id,

    'pain_point'::TEXT AS record_type,
    p.pain_point_id AS record_id,

    p.pain_point_description AS research_item,
    p.category,

    p.evidence_classification AS evidence_status,
    p.why_classified_this_way AS research_note,

    p.requires_client_validation
        AS client_validation_required,

    NULL::TEXT AS client_budget_known,
    NULL::TEXT AS client_purchase_intent_known,

    NULL::TEXT AS human_assessment,
    NULL::INTEGER AS human_score_out_of_20,
    NULL::TEXT AS human_analysis,

    p.source_id AS source_ids,
    p.source_url AS source_urls

FROM core.pain_points p

UNION ALL

SELECT
    o.project_id,

    'opportunity'::TEXT,
    o.opportunity_id,

    o.potential_service,
    NULL::TEXT,

    o.evidence_status,
    o.proposed_follow_up,

    NULL::TEXT,

    o.client_budget_known,
    o.client_purchase_intent_known,

    a.assessment_outcome,
    a.human_score_out_of_20::INTEGER,
    a.analysis_text,

    COALESCE(l.source_ids, o.source_basis_ids),
    l.source_urls

FROM core.opportunities o

LEFT JOIN opportunity_links l
    ON o.opportunity_id = l.opportunity_id

LEFT JOIN core.phase7_current_assessments a
    ON a.record_type = 'opportunity'
   AND a.record_id = o.opportunity_id;


-- ==================================================
-- 7. RESEARCH GAPS
-- One row per unresolved review item
-- ==================================================

CREATE OR REPLACE VIEW analytics.research_gaps AS

WITH opportunity_links AS (
    SELECT
        opportunity_id,
        STRING_AGG(
            source_url, E'\n' ORDER BY source_id
        ) FILTER (
            WHERE source_url IS NOT NULL
        ) AS source_urls
    FROM core.opportunity_source_basis
    GROUP BY opportunity_id
)

SELECT
    c.project_id,

    'claim'::TEXT AS record_type,
    c.claim_id AS record_id,

    c.extracted_statement_en AS research_item,

    q.primary_review_reason AS review_reason,
    c.evidence_status,

    COALESCE(
        NULLIF(BTRIM(c.source_url), ''),
        s.url
    ) AS source_urls

FROM core.claim_evidence_review_queue q

JOIN core.claims c
    ON q.claim_id = c.claim_id

LEFT JOIN core.sources s
    ON c.source_id = s.source_id

UNION ALL

SELECT
    q.project_id,

    q.record_type,
    q.record_id,

    COALESCE(
        p.pain_point_description,
        o.potential_service
    ) AS research_item,

    q.review_reason,
    q.evidence_status,

    COALESCE(p.source_url, l.source_urls)

FROM core.phase6_evidence_review_queue q

LEFT JOIN core.pain_points p
    ON q.record_type = 'pain_point'
   AND q.record_id = p.pain_point_id

LEFT JOIN core.opportunities o
    ON q.record_type = 'opportunity'
   AND q.record_id = o.opportunity_id

LEFT JOIN opportunity_links l
    ON q.record_type = 'opportunity'
   AND q.record_id = l.opportunity_id;


\ir project_evaluation.sql

-- ==================================================
-- 8. DATA CATALOG
-- Navigation guide for analysts
-- ==================================================

CREATE OR REPLACE VIEW analytics.catalog AS

SELECT
    dataset_name,
    row_definition,
    analytical_use,
    evidence_access

FROM (
    VALUES

    (
        'project_evaluation',
        'One question and supporting research record',
        'Start here for the five-part evaluation. Filter by question_id and project_id.',
        'source_urls'
    ),

    (
        'project_overview',
        'One project',
        'Start here for project identity, status and research coverage',
        'source_url'
    ),

    (
        'claim_evidence',
        'One research claim',
        'Examine statements, evidence qualifications and original sources',
        'source_url'
    ),

    (
        'project_metrics',
        'One numeric metric',
        'Analyze reported quantities, investment figures and measurement context',
        'source_url'
    ),

    (
        'organization_involvement',
        'One reported organization mention',
        'Identify reported project participants and source-backed roles',
        'source_url'
    ),

    (
        'project_timeline',
        'One observation, event or forecast',
        'Investigate project developments without confusing forecasts with events',
        'source_url'
    ),

    (
        'commercial_research',
        'One pain point or opportunity',
        'Examine commercial hypotheses and available human assessments',
        'source_urls'
    ),

    (
        'research_gaps',
        'One unresolved review item',
        'Identify missing evidence and validation requirements',
        'source_urls'
    )

) AS x(
    dataset_name,
    row_definition,
    analytical_use,
    evidence_access
);

\ir analyst_views.sql

COMMIT;
