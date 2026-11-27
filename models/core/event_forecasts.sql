
{{ config(materialized='view') }}

SELECT
    f.forecast_id,
    f.project_id,
    p.project_name_en,
    f.source_id,

    f.milestone_key,
    f.forecast_statement,

    f.target_date_raw,
    f.target_date_precision,
    f.target_date_exact,

    CASE
        WHEN f.target_date_precision = 'day'
        THEN EXTRACT(YEAR FROM f.target_date_exact)::INTEGER
        ELSE f.target_year
    END AS target_year,

    CASE
        WHEN f.target_date_precision = 'day'
        THEN EXTRACT(MONTH FROM f.target_date_exact)::INTEGER
        ELSE f.target_month
    END AS target_month,

    f.review_status,
    f.reviewed_by,
    f.reviewed_on,

    s.url AS source_url,
    s.published_date_exact AS source_published_date,
    f.imported_at

FROM raw.raw_event_forecasts f

LEFT JOIN {{ ref('projects') }} p
    ON f.project_id = p.project_id

LEFT JOIN {{ ref('sources') }} s
    ON f.source_id = s.source_id

WHERE f.review_status = 'verified'
