
{{ config(materialized='view') }}

SELECT
    o.opportunity_id,
    o.project_id,
    p.project_name_en,

    o.potential_service,
    o.evidence_status,

    o.client_budget_known,
    o.client_purchase_intent_known,

    o.proposed_follow_up,
    o.source_basis_ids

FROM {{ ref('stg_opportunities') }} o

LEFT JOIN {{ ref('projects') }} p
    ON o.project_id = p.project_id
