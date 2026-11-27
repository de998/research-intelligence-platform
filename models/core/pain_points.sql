
{{ config(materialized='view') }}

SELECT
    p.pain_point_id,
    p.project_id,
    pr.project_name_en,

    p.pain_point_description,
    p.category,
    p.evidence_classification,

    NULLIF(BTRIM(p.source_id), '') AS source_id,

    COALESCE(
        NULLIF(BTRIM(p.source_url), ''),
        s.url
    ) AS source_url,

    p.why_classified_this_way,
    p.requires_client_validation,
    p.accessed_date_exact

FROM {{ ref('stg_pain_points') }} p

LEFT JOIN {{ ref('projects') }} pr
    ON p.project_id = pr.project_id

LEFT JOIN {{ ref('sources') }} s
    ON NULLIF(BTRIM(p.source_id), '') = s.source_id
