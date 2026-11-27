{{ config(materialized='view') }}

WITH normalized AS (

    SELECT
        org_id,
        organization_name,

        LOWER(
            REGEXP_REPLACE(
                BTRIM(organization_name),
                '[[:space:][:punct:]]+',
                '',
                'g'
            )
        ) AS match_key

    FROM {{ ref('organizations') }}
    WHERE organization_name IS NOT NULL

),

possible_duplicates AS (

    SELECT
        a.org_id AS org_id_1,
        b.org_id AS org_id_2,

        a.organization_name AS organization_name_1,
        b.organization_name AS organization_name_2,

        a.match_key,

        'exact_normalized_name' AS match_rule,
        'needs_review' AS match_status

    FROM normalized a

    JOIN normalized b
        ON a.match_key = b.match_key
       AND a.org_id < b.org_id

    WHERE a.match_key <> ''

)

SELECT *
FROM possible_duplicates
