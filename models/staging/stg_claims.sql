{{ config(materialized='view') }}

WITH cleaned AS (
    SELECT
        {{ normalize_id("r.claim_id") }} AS claim_id,
        {{ normalize_id("r.research_project_id") }} AS project_id,
        {{ normalize_id("r.source_id") }} AS source_id,
        {{ clean_text("r.source_url") }} AS source_url,
        {{ clean_text("r.extracted_statement_en") }}
            AS extracted_statement_en,
        {{ normalize_category("r.claim_type") }} AS claim_type,
        {{ to_exact_numeric("r.reported_numeric_value") }}
            AS reported_numeric_value,
        {{ numeric_input_status("r.reported_numeric_value") }}
            AS numeric_value_status,
        {{ clean_text("r.unit") }} AS unit_raw,
        {{ normalize_unit("r.unit") }} AS unit_standardized,
        {{ normalize_category("r.measurement_status") }}
            AS measurement_status,
        {{ normalize_category("r.evidence_status") }}
            AS evidence_status,
        {{ normalize_category("r.review_status") }} AS review_status,
        {{ clean_text("r.accessed_date") }} AS accessed_date_raw
    FROM {{ source('research_raw', 'raw_claims') }} AS r
),
normalized AS (
    SELECT *,
        {{ normalize_date("accessed_date_raw") }}
            AS accessed_date_normalized
    FROM cleaned
)
SELECT *,
    CASE
        WHEN accessed_date_normalized IS NULL THEN 'missing'
        WHEN {{ is_valid_iso_date("accessed_date_normalized") }}
            THEN 'valid'
        ELSE 'invalid'
    END AS accessed_date_status,
    CASE
        WHEN {{ is_valid_iso_date("accessed_date_normalized") }}
            THEN accessed_date_normalized::DATE
        ELSE NULL::DATE
    END AS accessed_date_exact
FROM normalized
