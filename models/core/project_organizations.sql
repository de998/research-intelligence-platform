
{{ config(materialized='view') }}

WITH ranked_statuses AS (

    SELECT
        h.*,

        ROW_NUMBER() OVER (
            PARTITION BY
                h.project_id,
                h.canonical_org_id,
                h.role_type

            ORDER BY
                h.effective_on DESC,
                h.reviewed_on DESC,
                h.decision_id DESC
        ) AS status_rank

    FROM {{ ref('project_organization_status_history') }} h

    WHERE h.effective_on <=
        (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Shanghai')::date

      AND h.reviewed_on <=
        (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Shanghai')::date
)

SELECT
    project_id,
    canonical_org_id AS org_id,
    role_type,

    relationship_status AS current_status,

    effective_on AS status_effective_on,
    evidence_source_id,
    reviewed_by,
    reviewed_on,
    decision_id AS latest_decision_id

FROM ranked_statuses

WHERE status_rank = 1
