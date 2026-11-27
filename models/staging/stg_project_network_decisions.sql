
{{ config(materialized='view') }}

SELECT
    NULLIF(UPPER(BTRIM(project_id)), '') AS project_id,
    NULLIF(UPPER(BTRIM(network_id)), '') AS network_id,
    NULLIF(LOWER(BTRIM(relevance_type)), '') AS relevance_type,
    NULLIF(LOWER(BTRIM(classification_status)), '') AS classification_status,
    NULLIF(BTRIM(classification_rationale), '') AS classification_rationale,
    NULLIF(UPPER(BTRIM(source_id)), '') AS source_id,
    NULLIF(BTRIM(reviewed_by), '') AS reviewed_by,
    NULLIF(BTRIM(reviewed_at), '') AS reviewed_at

FROM {{ source(
    'research_network_input',
    'raw_project_network_decisions'
) }}
