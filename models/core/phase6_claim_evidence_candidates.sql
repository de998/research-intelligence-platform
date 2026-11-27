
{{ config(materialized='view') }}

SELECT
    'pain_point'::TEXT AS record_type,
    p.pain_point_id AS record_id,
    p.project_id,

    c.claim_id,
    c.source_id,

    c.extracted_statement_en,

    'shared_project_and_source_requires_review'
        AS relationship_status

FROM {{ ref('pain_points') }} p

INNER JOIN {{ ref('claims') }} c
    ON p.project_id = c.project_id
   AND p.source_id = c.source_id

UNION ALL

SELECT
    'opportunity'::TEXT AS record_type,
    o.opportunity_id AS record_id,
    o.project_id,

    c.claim_id,
    c.source_id,

    c.extracted_statement_en,

    'shared_project_and_source_requires_review'
        AS relationship_status

FROM {{ ref('opportunity_source_basis') }} o

INNER JOIN {{ ref('claims') }} c
    ON o.project_id = c.project_id
   AND o.source_id = c.source_id
