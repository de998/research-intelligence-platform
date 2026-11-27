
{{ config(materialized='view') }}

SELECT
    event_id,
    project_id,
    source_id,
    event_type,
    event_description,
    event_date_raw,
    event_date_exact,
    event_date_precision,
    evidence_basis,
    review_status,

    'event_requires_review' AS review_reason,

    imported_at

FROM raw.raw_project_events

WHERE review_status = 'proposed'
