
{{ config(materialized='view') }}

SELECT
    NULLIF(UPPER(BTRIM(decision_id)), '') AS decision_id,
    NULLIF(UPPER(BTRIM(mention_id)), '') AS mention_id,

    NULLIF(LOWER(BTRIM(role_type)), '') AS role_type,

    NULLIF(LOWER(BTRIM(relationship_status)), '')
        AS relationship_status,

    effective_on,

    NULLIF(LOWER(BTRIM(decision_status)), '')
        AS decision_status,

    NULLIF(BTRIM(reviewed_by), '') AS reviewed_by,
    reviewed_on,
    NULLIF(BTRIM(review_note), '') AS review_note

FROM {{ source(
    'research_project_org_status_input',
    'raw_project_org_status_decisions'
) }}
