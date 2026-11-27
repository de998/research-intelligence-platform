{{ config(materialized='view') }}

SELECT
    {{ normalize_id("r.raw_relation_id") }} AS mention_id,
    {{ normalize_id("r.research_project_id") }} AS project_id,
    {{ normalize_id("r.raw_org_id") }} AS org_id,
    {{ clean_text("r.role_as_reported") }} AS role_as_reported,
    {{ normalize_id("r.source_id") }} AS source_id,
    {{ clean_text("r.source_url") }} AS source_url,
    {{ clean_text("r.relationship_evidence_status") }}
        AS relationship_evidence_status
FROM {{ source('research_raw', 'raw_org_mentions') }} AS r
