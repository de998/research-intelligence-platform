
{{ config(materialized='view') }}

SELECT
    d.*,

    p.project_id AS pain_point_project_id,
    o.project_id AS opportunity_project_id,

    p.pain_point_description,
    o.potential_service,

    s.url AS evidence_source_url

FROM raw.raw_pain_point_opportunity_decisions d

LEFT JOIN {{ ref('pain_points') }} p
    ON d.pain_point_id = p.pain_point_id

LEFT JOIN {{ ref('opportunities') }} o
    ON d.opportunity_id = o.opportunity_id

LEFT JOIN {{ ref('sources') }} s
    ON d.evidence_source_id = s.source_id
