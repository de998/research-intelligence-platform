
{{ config(materialized='view') }}

SELECT
    'pain_point'::TEXT AS record_type,
    p.pain_point_id AS record_id,
    p.project_id,

    CASE
        WHEN p.source_id IS NULL
            THEN 'no_direct_source_reference'
        WHEN p.evidence_classification = 'reported_direct'
            THEN 'client_validation_required'
        ELSE 'hypothesis_or_inference_requires_validation'
    END AS review_reason,

    p.evidence_classification AS evidence_status

FROM {{ ref('pain_points') }} p

WHERE
    LOWER(COALESCE(p.requires_client_validation, '')) = 'yes'
    OR p.source_id IS NULL
    OR p.evidence_classification <> 'reported_direct'

UNION ALL

SELECT
    'opportunity'::TEXT AS record_type,
    o.opportunity_id AS record_id,
    o.project_id,

    'commercial_opportunity_requires_validation'
        AS review_reason,

    o.evidence_status

FROM {{ ref('opportunities') }} o

WHERE
    LOWER(COALESCE(o.evidence_status, '')) <> 'validated'
    OR LOWER(COALESCE(o.client_budget_known, '')) <> 'yes'
    OR LOWER(COALESCE(o.client_purchase_intent_known, '')) <> 'yes'
