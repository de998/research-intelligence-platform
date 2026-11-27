{% macro clean_text(expr) %}
    NULLIF(BTRIM(({{ expr }})::text), '')
{% endmacro %}

{% macro normalize_category(expr) %}
    REGEXP_REPLACE(
        LOWER({{ clean_text(expr) }}),
        '[[:space:]]+',
        '_',
        'g'
    )
{% endmacro %}
