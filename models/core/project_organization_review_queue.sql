
{{ config(materialized='view') }}

SELECT
    history_record_id,
    mention_id,
    project_id,
    reported_org_id,
    canonical_org_id,
    role_as_reported,
    relationship_evidence_status,
    source_id,
    source_published_date,

    CASE
        WHEN relationship_evidence_status
             ~* 'alias|distinct|legal'
            THEN 'identity_review'

        WHEN relationship_evidence_status
             ~* 'pending|provisional|verify'
            THEN 'evidence_review'

        ELSE 'role_review'
    END AS review_reason

FROM {{ ref('project_organization_history') }}

WHERE record_type = 'source_mention'
