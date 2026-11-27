
{{ config(materialized='view') }}

SELECT
    o.opportunity_id,
    o.project_id,

    BTRIM(x.source_id) AS source_id,

    s.publisher,
    s.url AS source_url,

    'referenced_source_not_verified_support'
        AS evidence_link_status

FROM {{ ref('opportunities') }} o

CROSS JOIN LATERAL
    regexp_split_to_table(
        COALESCE(o.source_basis_ids, ''),
        ';'
    ) AS x(source_id)

LEFT JOIN {{ ref('sources') }} s
    ON s.source_id = BTRIM(x.source_id)

WHERE NULLIF(BTRIM(x.source_id), '') IS NOT NULL
