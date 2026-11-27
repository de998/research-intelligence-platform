{% macro normalize_id(expr) %}
    UPPER({{ clean_text(expr) }})
{% endmacro %}
