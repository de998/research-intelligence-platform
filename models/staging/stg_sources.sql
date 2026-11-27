
{{ config(materialized='view') }}

-- STEP 1: Clean text, preserving the source values

WITH cleaned AS (

    SELECT
        NULLIF(BTRIM(source_id), '') AS source_id,
        NULLIF(BTRIM(publisher), '') AS publisher,
        NULLIF(BTRIM(title_zh), '') AS title,
        NULLIF(BTRIM(url), '') AS url,

        NULLIF(BTRIM(published_date), '') AS published_date_raw,
        NULLIF(BTRIM(accessed_date), '') AS accessed_date_raw,

        source_type,
        research_project_id,
        source_lineage,
        verification_note,
        full_text_stored

    FROM {{ source('research_raw', 'raw_sources') }}

),

-- STEP 2: Normalize separators in DATE COLUMNS ONLY

normalized AS (

    SELECT
        *,

        {{ normalize_date("published_date_raw") }}
            AS published_date_normalized,

        {{ normalize_date("accessed_date_raw") }}
            AS accessed_date_normalized

    FROM cleaned

),

-- STEP 3: Validate dates and identify precision

classified AS (

    SELECT
        *,

        CASE
            WHEN published_date_normalized IS NULL
                THEN 'unknown'

            WHEN published_date_normalized ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                 AND {{ is_valid_iso_date("published_date_normalized") }}
                THEN 'day'

            WHEN published_date_normalized ~ '^[0-9]{4}-[0-9]{2}$'
                 AND {{ is_valid_iso_date("published_date_normalized || '-01'") }}
                THEN 'month'

            WHEN published_date_normalized ~ '^[0-9]{4}$'
                 AND {{ is_valid_iso_date("published_date_normalized || '-01-01'") }}
                THEN 'year'

            ELSE 'invalid'
        END AS published_date_precision,

        CASE
            WHEN accessed_date_normalized IS NULL
                THEN 'missing'

            WHEN accessed_date_normalized ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                 AND {{ is_valid_iso_date("accessed_date_normalized") }}
                THEN 'valid'

            ELSE 'invalid'
        END AS accessed_date_status

    FROM normalized

)


-- STEP 4: Produce structured columns

SELECT
    source_id,
    publisher,
    title,
    url,

    published_date_raw,
    published_date_normalized,

    CASE
        WHEN published_date_precision IN ('year', 'month', 'day')
        THEN SUBSTRING(published_date_normalized FROM 1 FOR 4)::INTEGER
    END AS published_year,

    CASE
        WHEN published_date_precision IN ('month', 'day')
        THEN SUBSTRING(published_date_normalized FROM 6 FOR 2)::INTEGER
    END AS published_month,

    CASE
        WHEN published_date_precision = 'day'
        THEN SUBSTRING(published_date_normalized FROM 9 FOR 2)::INTEGER
    END AS published_day,

    published_date_precision,

    CASE
        WHEN published_date_precision = 'day'
        THEN published_date_normalized::DATE
    END AS published_date_exact,

    accessed_date_raw,
    accessed_date_normalized,

    CASE
        WHEN accessed_date_status = 'valid'
        THEN accessed_date_normalized::DATE
    END AS accessed_date_exact,

    accessed_date_status,

    source_type,
    research_project_id,
    source_lineage,
    verification_note,
    full_text_stored

FROM classified
