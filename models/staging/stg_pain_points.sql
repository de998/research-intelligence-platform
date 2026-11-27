{{ config(materialized='view') }}

WITH cleaned AS (
    SELECT
        {{ normalize_id("r.pain_point_id") }} AS pain_point_id,
        {{ normalize_id("r.research_project_id") }} AS project_id,
        {{ clean_text("r.pain_point_description") }}
            AS pain_point_description,
        {{ normalize_category("r.category") }} AS category,
        {{ normalize_category("r.evidence_classification") }}
            AS evidence_classification,
        {{ normalize_id("r.source_id") }} AS source_id,
        {{ clean_text("r.source_url") }} AS source_url,
        {{ clean_text("r.why_classified_this_way") }}
            AS why_classified_this_way,
        {{ normalize_category("r.requires_client_validation") }}
            AS requires_client_validation,
        {{ clean_text("r.accessed_date") }} AS accessed_date_raw
    FROM {{ source('research_raw', 'raw_pain_points') }} AS r
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
