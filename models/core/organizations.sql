{{ config(materialized='table') }}

SELECT
    org_id,
    organization_name
FROM {{ ref('stg_organizations') }}
