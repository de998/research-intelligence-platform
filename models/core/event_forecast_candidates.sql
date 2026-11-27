
{{ config(materialized='view') }}

SELECT
    'FCAND:' || p.project_id AS candidate_id,

    p.project_id,
    p.project_name_en,
    p.source_id,
    p.source_url,

    p.observed_project_stage AS evidence_text,
    p.as_of_date_exact AS research_as_of_date,

    'potential_forecast_in_project_stage'
        AS candidate_reason,

    'candidate_needs_manual_date_review'
        AS candidate_status

FROM {{ ref('stg_projects') }} p

WHERE p.observed_project_stage ~*
    '(target|planned|expected|forecast|deadline)'
