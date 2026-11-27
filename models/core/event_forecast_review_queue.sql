
{{ config(materialized='view') }}

SELECT
    forecast_id,
    project_id,
    source_id,
    milestone_key,
    forecast_statement,

    target_date_raw,
    target_date_precision,
    target_date_exact,
    target_year,
    target_month,

    review_status,
    'forecast_requires_review' AS review_reason,

    imported_at

FROM raw.raw_event_forecasts

WHERE review_status = 'proposed'
