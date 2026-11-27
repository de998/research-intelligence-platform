
{{ config(materialized='table') }}

WITH numeric_claims AS (

    SELECT
        c.claim_id,
        c.project_id,
        c.source_id,
        c.source_url,
        c.extracted_statement_en,
        c.claim_type,
        c.reported_numeric_value,
        c.numeric_value_status,
        c.unit_raw,
        c.unit_standardized,
        c.measurement_status,
        c.evidence_status,
        c.review_status,
        c.accessed_date_exact

    FROM {{ ref('claims') }} AS c

    WHERE c.numeric_value_status = 'valid'
      AND c.reported_numeric_value IS NOT NULL

)

SELECT
    'MET:' || c.claim_id AS metric_id,

    c.claim_id,
    c.project_id,
    c.source_id,

    c.claim_type AS metric_type,
    c.extracted_statement_en AS metric_description,

    c.reported_numeric_value AS metric_value,
    c.unit_raw,
    c.unit_standardized,

    c.measurement_status,
    c.evidence_status,
    c.review_status,

    c.source_url AS claim_source_url,
    s.url AS source_catalog_url,

    s.published_date_exact AS source_published_date,
    s.published_date_precision
        AS source_published_precision,

    c.accessed_date_exact AS claim_accessed_date

FROM numeric_claims AS c

LEFT JOIN {{ ref('sources') }} AS s
    ON c.source_id = s.source_id
