
SELECT
    project_id,
    canonical_org_id,
    role_type,
    effective_on

FROM {{ ref('project_organization_status_history') }}

GROUP BY
    project_id,
    canonical_org_id,
    role_type,
    effective_on

HAVING COUNT(DISTINCT relationship_status) > 1
