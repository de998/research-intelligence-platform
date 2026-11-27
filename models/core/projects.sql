{{ config(materialized='table') }}

SELECT
    project_id,
    project_name_zh,
    project_name_en,
    industry,
    location,
    source_id
FROM {{ ref('stg_projects') }}
