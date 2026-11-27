
SELECT
    claim_id,
    reported_numeric_value,
    numeric_value_status

FROM {{ ref('claims') }}

WHERE
    (
        numeric_value_status = 'valid'
        AND reported_numeric_value IS NULL
    )

    OR

    (
        numeric_value_status IN ('missing', 'invalid')
        AND reported_numeric_value IS NOT NULL
    )
