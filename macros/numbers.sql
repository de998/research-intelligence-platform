{% macro to_exact_numeric(expr) %}
    (
        CASE
            WHEN NULLIF(BTRIM(({{ expr }})::text), '')
                 ~ '^[+-]?[0-9]+([.][0-9]+)?$'
            THEN BTRIM(({{ expr }})::text)::NUMERIC
            ELSE NULL::NUMERIC
        END
    )
{% endmacro %}

{% macro numeric_input_status(expr) %}
    (
        CASE
            WHEN NULLIF(BTRIM(({{ expr }})::text), '')
                 IS NULL
            THEN 'missing'
            WHEN BTRIM(({{ expr }})::text)
                 ~ '^[+-]?[0-9]+([.][0-9]+)?$'
            THEN 'valid'
            ELSE 'invalid'
        END
    )
{% endmacro %}
