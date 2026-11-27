
{{ config(materialized='table') }}

SELECT
    network_id,
    network_name_en,
    network_name_zh
FROM (
    VALUES
        ('NET01', 'National Water Network', '国家水网'),
        ('NET02', 'New-Type Power Grid', '新型电网'),
        ('NET03', 'Computing Power Network', '算力网'),
        ('NET04', 'Next-Generation Communication Network', '新一代通信网'),
        ('NET05', 'Urban Underground Pipeline Network', '城市地下管网'),
        ('NET06', 'Logistics Network', '物流网')
) AS n(
    network_id,
    network_name_en,
    network_name_zh
)
