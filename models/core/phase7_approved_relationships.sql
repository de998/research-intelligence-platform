
{{ config(materialized='view') }}

WITH ranked AS (

    SELECT
        d.*,

        ROW_NUMBER() OVER (
            PARTITION BY
                pain_point_id,
                opportunity_id
            ORDER BY
                decided_on DESC,
                imported_at DESC,
                decision_id DESC
        ) AS decision_rank

    FROM {{ ref('phase7_relationship_decision_history') }} d

    WHERE decided_on <=
        (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Shanghai')::DATE
)

SELECT
    decision_id,

    pain_point_id,
    opportunity_id,

    pain_point_project_id AS project_id,

    pain_point_description,
    potential_service,

    rationale,
    evidence_source_id,
    evidence_source_url,

    reviewer_name,
    decided_on

FROM ranked

WHERE decision_rank = 1
  AND decision_outcome = 'approved'
  AND pain_point_project_id IS NOT NULL
  AND pain_point_project_id = opportunity_project_id
