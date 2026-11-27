
{{ config(materialized='table') }}

SELECT
    'MENTION:' || m.mention_id AS history_record_id,

    m.mention_id,
    m.project_id,

    m.reported_org_id,
    m.canonical_org_id,
    m.mapping_status,

    m.role_as_reported,
    m.relationship_evidence_status,

    m.source_id,
    m.source_url,

    s.published_date_exact AS source_published_date,
    s.accessed_date_exact AS source_accessed_date,

    'source_mention' AS record_type

FROM {{ ref('org_mentions_resolved') }} AS m

LEFT JOIN {{ ref('sources') }} AS s
    ON m.source_id = s.source_id
