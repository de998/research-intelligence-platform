{{ config(materialized='view') }}

SELECT
    {{ normalize_id("r.opportunity_id") }} AS opportunity_id,
    {{ normalize_id("r.research_project_id") }} AS project_id,
    {{ clean_text("r.potential_service") }} AS potential_service,
    {{ normalize_category("r.evidence_status") }} AS evidence_status,
    {{ normalize_category("r.client_budget_known") }}
        AS client_budget_known,
    {{ normalize_category("r.client_purchase_intent_known") }}
        AS client_purchase_intent_known,
    {{ clean_text("r.proposed_follow_up") }} AS proposed_follow_up,
    {{ clean_text("r.source_basis_ids") }} AS source_basis_ids
FROM {{ source('research_raw', 'raw_opportunities') }} AS r
