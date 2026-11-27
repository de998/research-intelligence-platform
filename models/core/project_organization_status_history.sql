
{{ config(materialized='table') }}

SELECT
    d.decision_id,
    d.mention_id,

    m.project_id,
    m.reported_org_id,
    m.canonical_org_id,

    d.role_type,
    d.relationship_status,
    d.effective_on,

    m.source_id AS evidence_source_id,
    m.source_url,
    m.role_as_reported,

    d.reviewed_by,
    d.reviewed_on,
    d.review_note

FROM {{ ref('stg_project_org_status_decisions') }} d

JOIN {{ ref('org_mentions_resolved') }} m
    ON d.mention_id = m.mention_id

WHERE d.decision_status = 'verified'
  AND d.effective_on IS NOT NULL
  AND d.reviewed_by IS NOT NULL
  AND d.reviewed_on IS NOT NULL
