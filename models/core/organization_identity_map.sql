
{{ config(materialized='table') }}

WITH verified_decisions AS (

    SELECT
        alias_org_id,
        canonical_org_id,
        evidence_source_id,
        reviewed_by,
        reviewed_at

    FROM {{ ref('stg_organization_identity_decisions') }}

    WHERE decision_status = 'verified'
      AND evidence_source_id IS NOT NULL
      AND reviewed_by IS NOT NULL
      AND reviewed_at IS NOT NULL

)

SELECT
    o.org_id AS incoming_org_id,

    COALESCE(
        d.canonical_org_id,
        o.org_id
    ) AS canonical_org_id,

    CASE
        WHEN d.alias_org_id IS NOT NULL
            THEN 'verified_alias'
        ELSE 'self'
    END AS mapping_status,

    d.evidence_source_id,
    d.reviewed_by,
    d.reviewed_at

FROM {{ ref('organizations') }} o

LEFT JOIN verified_decisions d
    ON o.org_id = d.alias_org_id
