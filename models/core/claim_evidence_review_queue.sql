
{{ config(materialized='view') }}

WITH inspected_claims AS (

    SELECT
        c.claim_id,
        c.project_id,
        c.source_id,

        c.extracted_statement_en,
        c.claim_type,

        c.reported_numeric_value,
        c.numeric_value_status,
        c.unit_standardized,

        c.measurement_status,
        c.evidence_status,
        c.review_status,

        s.publisher,
        s.published_date_exact,

        -- Rule 1: Claim has not completed review
        (
            c.review_status IS NULL
            OR c.review_status ~*
                'pending|unreviewed|needs_review'
        ) AS needs_claim_review,

        -- Rule 2: Evidence needs further checking
        (
            c.evidence_status IS NULL
            OR c.evidence_status ~*
                'not_independently_audited|unverified|provisional|pending'
        ) AS needs_evidence_audit,

        -- Rule 3: Numeric input needs attention
        (
            c.numeric_value_status IS NULL
            OR c.numeric_value_status = 'invalid'
        ) AS needs_numeric_check,

        -- Rule 4: Neither record has a source URL
        (
            COALESCE(
                NULLIF(BTRIM(c.source_url), ''),
                NULLIF(BTRIM(s.url), '')
            ) IS NULL
        ) AS missing_source_url

    FROM {{ ref('claims') }} c

    LEFT JOIN {{ ref('sources') }} s
        ON c.source_id = s.source_id

)

SELECT
    *,

    CASE
        WHEN needs_numeric_check
            THEN 'numeric_check'

        WHEN missing_source_url
            THEN 'missing_source_url'

        WHEN needs_claim_review
            THEN 'claim_review_pending'

        WHEN needs_evidence_audit
            THEN 'evidence_audit_pending'

    END AS primary_review_reason

FROM inspected_claims

WHERE
    needs_numeric_check
    OR missing_source_url
    OR needs_claim_review
    OR needs_evidence_audit
