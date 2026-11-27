
{{ config(materialized='view') }}

WITH network_rules AS (

    SELECT *
    FROM (
        VALUES
            ('NET01',
             'water network|water supply|reservoir|水网|供水|水利',
             'water_v1'),

            ('NET02',
             'power grid|electric grid|电网|输电|配电',
             'power_v1'),

            ('NET03',
             'computing power|data center|算力|数据中心',
             'computing_v1'),

            ('NET04',
             'telecom|communication|5g|6g|通信|光纤',
             'communication_v1'),

            ('NET05',
             'underground pipeline|utility tunnel|地下管网|综合管廊',
             'pipeline_v1'),

            ('NET06',
             'logistics|freight|multimodal|物流|货运|多式联运',
             'logistics_v1')

    ) AS r(network_id, keyword_pattern, rule_id)

),

project_text AS (

    SELECT
        project_id,
        COALESCE(project_name_en, '') || ' ' ||
        COALESCE(project_name_zh, '') || ' ' ||
        COALESCE(industry, '') AS searchable_text

    FROM {{ ref('projects') }}

),

candidate_matches AS (

    SELECT
        p.project_id,
        n.network_id,
        r.rule_id

    FROM project_text p

    JOIN network_rules r
        ON p.searchable_text ~* r.keyword_pattern

    JOIN {{ ref('networks') }} n
        ON r.network_id = n.network_id

)

SELECT
    project_id || ':' || network_id AS project_network_key,
    project_id,
    network_id,
    'candidate' AS relevance_type,
    'proposed' AS classification_status,
    'keyword_rule' AS mapping_method,
    rule_id,
    'Automatic keyword match; requires review'
        AS classification_rationale

FROM candidate_matches
