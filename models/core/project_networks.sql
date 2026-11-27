
{{ config(materialized='table') }}

SELECT
    project_id || ':' || network_id AS project_network_key,
    project_id,
    network_id,
    relevance_type,
    classification_status,
    classification_rationale,
    source_id,
    reviewed_by,
    reviewed_at

FROM {{ ref('stg_project_network_decisions') }}
