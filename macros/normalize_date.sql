
{% macro normalize_date(date_expr) %}

(
    WITH input_value AS (
        SELECT
            NULLIF(BTRIM({{ date_expr }}), '') AS original
    ),

    separators AS (
        SELECT
            original,

            REGEXP_REPLACE(
                TRANSLATE(
                    TRANSLATE(
                        original,
                        './' || CHR(92) || '．／＼–—−‐‑－',
                        REPEAT('-', 12)
                    ),
                    '年月日',
                    '--'
                ),
                '[[:space:]]*-[[:space:]]*',
                '-',
                'g'
            ) AS date_text

        FROM input_value
    ),

    prepared AS (
        SELECT
            CASE
                WHEN original ~ '[年月]$'
                    THEN REGEXP_REPLACE(date_text, '-$', '')
                ELSE date_text
            END AS value
        FROM separators
    ),

    parsed AS (
        SELECT
            value,

            REGEXP_MATCH(
                value,
                '^([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})$'
            ) AS ymd,

            REGEXP_MATCH(
                value,
                '^([0-9]{4})-([0-9]{1,2})$'
            ) AS ym,

            REGEXP_MATCH(
                value,
                '^([A-Za-z]+)[[:space:]]+([0-9]{1,2}),?[[:space:]]+([0-9]{4})$',
                'i'
            ) AS mdy,

            REGEXP_MATCH(
                value,
                '^([0-9]{1,2})[[:space:]]+([A-Za-z]+)[[:space:]]+([0-9]{4})$',
                'i'
            ) AS dmy,

            REGEXP_MATCH(
                value,
                '^([A-Za-z]+)[[:space:]]+([0-9]{4})$',
                'i'
            ) AS my

        FROM prepared
    ),

    with_month AS (
        SELECT
            p.*,
            m.month_number

        FROM parsed p

        LEFT JOIN (
            VALUES
                ('JANUARY', '01'), ('JAN', '01'),
                ('FEBRUARY', '02'), ('FEB', '02'),
                ('MARCH', '03'), ('MAR', '03'),
                ('APRIL', '04'), ('APR', '04'),
                ('MAY', '05'),
                ('JUNE', '06'), ('JUN', '06'),
                ('JULY', '07'), ('JUL', '07'),
                ('AUGUST', '08'), ('AUG', '08'),
                ('SEPTEMBER', '09'), ('SEP', '09'),
                ('OCTOBER', '10'), ('OCT', '10'),
                ('NOVEMBER', '11'), ('NOV', '11'),
                ('DECEMBER', '12'), ('DEC', '12')
        ) AS m(month_name, month_number)

          ON UPPER(
              COALESCE(
                  (p.mdy)[1],
                  (p.dmy)[2],
                  (p.my)[1]
              )
          ) = m.month_name
    )

    SELECT
        CASE
            WHEN ymd IS NOT NULL
                THEN (ymd)[1] || '-'
                     || LPAD((ymd)[2], 2, '0') || '-'
                     || LPAD((ymd)[3], 2, '0')

            WHEN ym IS NOT NULL
                THEN (ym)[1] || '-'
                     || LPAD((ym)[2], 2, '0')

            WHEN mdy IS NOT NULL
                 AND month_number IS NOT NULL
                THEN (mdy)[3] || '-'
                     || month_number || '-'
                     || LPAD((mdy)[2], 2, '0')

            WHEN dmy IS NOT NULL
                 AND month_number IS NOT NULL
                THEN (dmy)[3] || '-'
                     || month_number || '-'
                     || LPAD((dmy)[1], 2, '0')

            WHEN my IS NOT NULL
                 AND month_number IS NOT NULL
                THEN (my)[2] || '-'
                     || month_number

            ELSE value
        END

    FROM with_month
)

{% endmacro %}
