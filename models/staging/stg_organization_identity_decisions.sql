
{{ config(materialized='view') }}

SELECT
    NULLIF(UPPER(BTRIM(alias_org_id)), '')
        AS alias_org_id,

    NULLIF(UPPER(BTRIM(canonical_org_id)), '')
        AS canonical_org_id,

    NULLIF(LOWER(BTRIM(decision_status)), '')
        AS decision_status,

    NULLIF(UPPER(BTRIM(evidence_source_id)), '')
        AS evidence_source_id,

    NULLIF(BTRIM(reviewed_by), '')
        AS reviewed_by,

    NULLIF(BTRIM(reviewed_at), '')
        AS reviewed_at,

    NULLIF(BTRIM(resolution_note), '')
        AS resolution_note

FROM {{ source(
    'research_identity_input',
    'raw_organization_identity_decisions'
) }}
