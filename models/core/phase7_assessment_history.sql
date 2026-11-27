
{{ config(materialized='view') }}

WITH subjects AS (

    SELECT
        'project'::TEXT AS record_type,
        project_id AS record_id,
        project_id,
        project_name_en AS subject_label
    FROM {{ ref('projects') }}

    UNION ALL

    SELECT
        'pain_point'::TEXT,
        pain_point_id,
        project_id,
        pain_point_description
    FROM {{ ref('pain_points') }}

    UNION ALL

    SELECT
        'opportunity'::TEXT,
        opportunity_id,
        project_id,
        potential_service
    FROM {{ ref('opportunities') }}

)

SELECT
    a.*,
    r.project_id,
    r.subject_label,
    s.url AS evidence_source_url

FROM raw.raw_research_assessments a

LEFT JOIN subjects r
    ON a.record_type = r.record_type
   AND a.record_id = r.record_id

LEFT JOIN {{ ref('sources') }} s
    ON a.evidence_source_id = s.source_id
