SELECT *
FROM {{ ref('stg_organization_identity_decisions') }}
WHERE decision_status = 'verified'
  AND (
      evidence_source_id IS NULL
      OR reviewed_by IS NULL
      OR reviewed_at IS NULL
      OR alias_org_id = canonical_org_id
  )
