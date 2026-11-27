{{ config(materialized='view') }}

WITH cleaned AS (
    SELECT
        {{ normalize_id("r.project_id") }} AS project_id,
        {{ clean_text("r.project_name_zh") }} AS project_name_zh,
        {{ clean_text("r.project_name_en") }} AS project_name_en,
        {{ normalize_category("r.industry") }} AS industry,
        {{ clean_text("r.location") }} AS location,
        {{ normalize_id("r.source_id") }} AS source_id,
        {{ clean_text("r.source_url") }} AS source_url,
        {{ clean_text("r.observed_project_stage") }} AS observed_project_stage,
        {{ clean_text("r.as_of_date") }} AS as_of_date_raw,
        {{ clean_text("r.review_note") }} AS review_note
    FROM {{ source('research_raw', 'raw_projects') }} AS r
),
normalized AS (
    SELECT *,
        {{ normalize_date("as_of_date_raw") }}
            AS as_of_date_normalized
    FROM cleaned
)
SELECT *,
    CASE
        WHEN as_of_date_normalized IS NULL THEN 'missing'
        WHEN {{ is_valid_iso_date("as_of_date_normalized") }}
            THEN 'valid'
        ELSE 'invalid'
    END AS as_of_date_status,
    CASE
        WHEN {{ is_valid_iso_date("as_of_date_normalized") }}
            THEN as_of_date_normalized::DATE
        ELSE NULL::DATE
    END AS as_of_date_exact
FROM normalized
