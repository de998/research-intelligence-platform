
{% macro is_valid_iso_date(date_expr) %}

(
    CASE
        WHEN ({{ date_expr }}) ~
             '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'

        THEN
            CASE
                WHEN SUBSTRING(({{ date_expr }}) FROM 1 FOR 4)::INTEGER
                         BETWEEN 1 AND 9999
                 AND SUBSTRING(({{ date_expr }}) FROM 6 FOR 2)::INTEGER
                         BETWEEN 1 AND 12

                THEN
                    SUBSTRING(({{ date_expr }}) FROM 9 FOR 2)::INTEGER
                    BETWEEN 1 AND EXTRACT(
                        DAY FROM (
                            MAKE_DATE(
                                SUBSTRING(({{ date_expr }}) FROM 1 FOR 4)::INTEGER,
                                SUBSTRING(({{ date_expr }}) FROM 6 FOR 2)::INTEGER,
                                1
                            ) + INTERVAL '1 month' - INTERVAL '1 day'
                        )
                    )

                ELSE FALSE
            END

        ELSE FALSE
    END
)

{% endmacro %}
