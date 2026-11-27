
{{ config(materialized='view') }}

WITH pain_counts AS (

    SELECT
        project_id,
        COUNT(*) AS pain_point_count
    FROM {{ ref('pain_points') }}
    GROUP BY project_id
),

opportunity_counts AS (

    SELECT
        project_id,
        COUNT(*) AS opportunity_count
    FROM {{ ref('opportunities') }}
    GROUP BY project_id
),

assessment_counts AS (

    SELECT
        project_id,
        COUNT(*) AS current_assessment_count,

        COUNT(*) FILTER (
            WHERE record_type = 'opportunity'
              AND assessment_outcome = 'positive'
        ) AS positive_opportunity_assessments

    FROM {{ ref('phase7_current_assessments') }}
    GROUP BY project_id
),

approved_counts AS (

    SELECT
        project_id,
        COUNT(*) AS approved_relationship_count
    FROM {{ ref('phase7_approved_relationships') }}
    GROUP BY project_id
)

SELECT
    p.project_id,
    p.project_name_en,
    p.industry,
    p.location,

    COALESCE(pc.pain_point_count, 0)
        AS pain_point_count,

    COALESCE(oc.opportunity_count, 0)
        AS opportunity_count,

    COALESCE(ac.current_assessment_count, 0)
        AS current_assessment_count,

    COALESCE(ac.positive_opportunity_assessments, 0)
        AS positive_opportunity_assessments,

    COALESCE(rc.approved_relationship_count, 0)
        AS approved_relationship_count

FROM {{ ref('projects') }} p

LEFT JOIN pain_counts pc
    ON p.project_id = pc.project_id

LEFT JOIN opportunity_counts oc
    ON p.project_id = oc.project_id

LEFT JOIN assessment_counts ac
    ON p.project_id = ac.project_id

LEFT JOIN approved_counts rc
    ON p.project_id = rc.project_id
