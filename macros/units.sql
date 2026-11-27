{% macro normalize_unit(expr) %}
    (
        CASE
            WHEN {{ clean_text(expr) }} IS NULL
                THEN NULL

            WHEN LOWER({{ clean_text(expr) }})
                 IN ('km', 'kilometer', 'kilometers',
                     'kilometre', 'kilometres')
                THEN 'km'

            WHEN LOWER({{ clean_text(expr) }})
                 IN ('square_metres', 'square_meters',
                     'm2', 'm^2', '㎡')
                THEN 'square_metres'

            WHEN LOWER({{ clean_text(expr) }})
                 IN ('square_kilometres', 'square_kilometers',
                     'km2', 'km^2', '㎢')
                THEN 'square_kilometres'

            WHEN LOWER({{ clean_text(expr) }})
                 IN ('cny', 'rmb', 'yuan', '人民币')
                THEN 'CNY'

            WHEN LOWER({{ clean_text(expr) }})
                 IN ('percent', '%')
                THEN 'percent'

            WHEN LOWER({{ clean_text(expr) }})
                 = 'percent_lower_bound'
                THEN 'percent_lower_bound'

            WHEN LOWER({{ clean_text(expr) }})
                 = 'percent_enterprise_funded'
                THEN 'percent_enterprise_funded'

            WHEN LOWER({{ clean_text(expr) }})
                 = 'kw_per_space'
                THEN 'kW_per_space'

            WHEN LOWER({{ clean_text(expr) }})
                 = 'cny_per_station_month'
                THEN 'CNY_per_station_month'

            ELSE {{ clean_text(expr) }}
        END
    )
{% endmacro %}
