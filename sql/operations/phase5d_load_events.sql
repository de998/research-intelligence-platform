
\set ON_ERROR_STOP on

BEGIN;

CREATE TEMP TABLE incoming_project_events (
    LIKE raw.raw_project_events INCLUDING DEFAULTS
) ON COMMIT DROP;

\copy incoming_project_events (event_id,project_id,source_id,event_type,event_description,event_date_raw,event_date_exact,event_date_precision,evidence_basis,review_status,reviewed_by,reviewed_on) FROM 'inputs/project_events.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

-- Duplicate IDs in one CSV are not allowed.
-- Existing IDs must not be silently changed.

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM incoming_project_events
        GROUP BY event_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicate event IDs in import CSV';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM incoming_project_events i
        JOIN raw.raw_project_events e
            ON i.event_id = e.event_id
        WHERE ROW(
            i.project_id,
            i.source_id,
            i.event_type,
            i.event_description,
            i.event_date_raw,
            i.event_date_exact,
            i.event_date_precision,
            i.evidence_basis,
            i.review_status,
            i.reviewed_by,
            i.reviewed_on
        ) IS DISTINCT FROM ROW(
            e.project_id,
            e.source_id,
            e.event_type,
            e.event_description,
            e.event_date_raw,
            e.event_date_exact,
            e.event_date_precision,
            e.evidence_basis,
            e.review_status,
            e.reviewed_by,
            e.reviewed_on
        )
    ) THEN
        RAISE EXCEPTION
            'Existing event ID has changed; import rejected';
    END IF;
END
$$;

INSERT INTO raw.raw_project_events (
    event_id,
    project_id,
    source_id,
    event_type,
    event_description,
    event_date_raw,
    event_date_exact,
    event_date_precision,
    evidence_basis,
    review_status,
    reviewed_by,
    reviewed_on
)
SELECT
    event_id,
    project_id,
    source_id,
    event_type,
    event_description,
    event_date_raw,
    event_date_exact,
    event_date_precision,
    evidence_basis,
    review_status,
    reviewed_by,
    reviewed_on
FROM incoming_project_events
ON CONFLICT (event_id) DO NOTHING;

COMMIT;

SELECT COUNT(*) AS total_stored_events
FROM raw.raw_project_events;
