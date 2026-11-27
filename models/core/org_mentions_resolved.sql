
{{ config(materialized='view') }}

SELECT
    m.mention_id,
    m.project_id,

    m.org_id AS reported_org_id,
    im.canonical_org_id,

    m.role_as_reported,
    m.source_id,
    m.source_url,
    m.relationship_evidence_status,

    im.mapping_status

FROM {{ ref('org_mentions') }} m

LEFT JOIN {{ ref('organization_identity_map') }} im
    ON m.org_id = im.incoming_org_id
