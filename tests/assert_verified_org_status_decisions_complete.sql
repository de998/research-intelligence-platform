
SELECT *
FROM {{ ref('stg_project_org_status_decisions') }}

WHERE decision_status = 'verified'
  AND (
      effective_on IS NULL
      OR reviewed_by IS NULL
      OR reviewed_on IS NULL
      OR mention_id IS NULL
  )
