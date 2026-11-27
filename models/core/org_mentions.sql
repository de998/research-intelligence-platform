{{ config(materialized='table') }}

SELECT
    mention_id,
    project_id,
    org_id,
    role_as_reported,
    source_id,
    source_url,
    relationship_evidence_status

FROM {{ ref('stg_org_mentions') }}
