
{{ config(materialized='view') }}

SELECT
    o.observation_id,

    o.project_id,
    p.project_name_en,

    o.source_id,

    COALESCE(
        NULLIF(BTRIM(o.source_url), ''),
        s.url
    ) AS source_url,

    o.observed_project_stage,

    o.as_of_date_exact AS observation_as_of_date,
    o.as_of_date_raw,

    o.review_note,

    s.published_date_exact AS source_published_date,
    s.published_date_precision,

    o.imported_at

FROM raw.raw_project_observations AS o

LEFT JOIN {{ ref('projects') }} AS p
    ON o.project_id = p.project_id

LEFT JOIN {{ ref('sources') }} AS s
    ON o.source_id = s.source_id
