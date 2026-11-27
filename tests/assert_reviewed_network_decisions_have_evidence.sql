SELECT
    project_id,
    network_id,
    source_id,
    reviewed_by,
    reviewed_at
FROM {{ ref('project_networks') }}
WHERE classification_status = 'reviewed'
  AND (
      source_id IS NULL
      OR reviewed_by IS NULL
      OR reviewed_at IS NULL
  )
