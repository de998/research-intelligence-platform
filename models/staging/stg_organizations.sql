{{ config(materialized='view') }}

SELECT
    {{ normalize_id("r.raw_org_id") }} AS org_id,
    {{ clean_text("r.name_as_published") }} AS organization_name,
    {{ clean_text("r.candidate_project_ids") }}
        AS candidate_project_ids,
    {{ clean_text("r.role_as_reported") }} AS role_as_reported,
    {{ normalize_id("r.source_id") }} AS source_id,
    {{ clean_text("r.source_url") }} AS source_url,
    {{ clean_text("r.verification_status") }} AS verification_status
FROM {{ source('research_raw', 'raw_organizations') }} AS r
