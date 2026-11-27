
{{ config(materialized='view') }}

WITH ranked AS (

    SELECT
        h.*,

        ROW_NUMBER() OVER (
            PARTITION BY record_type, record_id
            ORDER BY
                assessed_on DESC,
                imported_at DESC,
                assessment_id DESC
        ) AS assessment_rank

    FROM {{ ref('phase7_assessment_history') }} h

    WHERE assessed_on <=
        (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Shanghai')::DATE
)

SELECT
    assessment_id,
    record_type,
    record_id,
    project_id,
    subject_label,

    assessment_outcome,
    analysis_text,

    evidence_source_id,
    evidence_source_url,

    strategic_fit_score,
    demand_score,
    feasibility_score,
    evidence_score,

    CASE
        WHEN strategic_fit_score IS NOT NULL
         AND demand_score IS NOT NULL
         AND feasibility_score IS NOT NULL
         AND evidence_score IS NOT NULL
        THEN
            strategic_fit_score
            + demand_score
            + feasibility_score
            + evidence_score
        ELSE NULL
    END AS human_score_out_of_20,

    analyst_name,
    assessed_on,
    imported_at

FROM ranked
WHERE assessment_rank = 1
