
{{ config(materialized='view') }}

SELECT
    e.event_id,
    e.project_id,
    p.project_name_en,
    e.source_id,

    e.event_type,
    e.event_description,

    e.event_date_raw,
    e.event_date_exact,
    e.event_date_precision,

    e.evidence_basis,
    e.review_status,
    e.reviewed_by,
    e.reviewed_on,

    s.url AS source_url,
    s.published_date_exact AS source_published_date,
    s.published_date_precision AS source_date_precision,

    e.imported_at

FROM raw.raw_project_events e

LEFT JOIN {{ ref('projects') }} p
    ON e.project_id = p.project_id

LEFT JOIN {{ ref('sources') }} s
    ON e.source_id = s.source_id

WHERE e.review_status = 'verified'
