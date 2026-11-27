
{{ config(materialized='view') }}

WITH combined AS (

    SELECT
        COALESCE(a.project_id, c.project_id) AS project_id,
        COALESCE(a.network_id, c.network_id) AS network_id,

        a.relevance_type AS assigned_relevance,
        a.classification_status AS assignment_status,

        c.rule_id,

        CASE
            WHEN a.classification_status = 'reviewed'
                THEN 'already_reviewed'

            WHEN a.project_id IS NOT NULL
                THEN 'proposed_needs_review'

            ELSE 'new_candidate_needs_review'
        END AS review_action

    FROM {{ ref('project_networks') }} a

    FULL OUTER JOIN {{ ref('project_network_candidates') }} c
        ON a.project_id = c.project_id
       AND a.network_id = c.network_id

)

SELECT *
FROM combined

WHERE review_action <> 'already_reviewed'
