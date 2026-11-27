
{{ config(materialized='table') }}

SELECT
    claim_id,
    project_id,
    source_id,
    source_url,

    extracted_statement_en,
    claim_type,

    reported_numeric_value,
    numeric_value_status,

    unit_raw,
    unit_standardized,

    measurement_status,
    evidence_status,
    review_status,

    accessed_date_raw,
    accessed_date_normalized,
    accessed_date_status,
    accessed_date_exact

FROM {{ ref('stg_claims') }}
