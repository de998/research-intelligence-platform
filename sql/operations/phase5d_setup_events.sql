
BEGIN;

CREATE TABLE IF NOT EXISTS raw.raw_project_events (
    event_id TEXT PRIMARY KEY,
    project_id TEXT NOT NULL,
    source_id TEXT NOT NULL,

    event_type TEXT NOT NULL,
    event_description TEXT NOT NULL,

    event_date_raw TEXT,
    event_date_exact DATE,
    event_date_precision TEXT NOT NULL
        CHECK (event_date_precision IN
            ('day', 'month', 'year', 'unknown')),

    evidence_basis TEXT NOT NULL DEFAULT 'source_reported',

    review_status TEXT NOT NULL
        CHECK (review_status IN ('proposed', 'verified')),
    reviewed_by TEXT,
    reviewed_on DATE,

    imported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT event_date_consistency CHECK (
        (event_date_precision = 'day'
         AND event_date_exact IS NOT NULL)
        OR
        (event_date_precision <> 'day'
         AND event_date_exact IS NULL)
    ),

    CONSTRAINT verified_event_requires_review CHECK (
        review_status <> 'verified'
        OR
        (
            NULLIF(BTRIM(reviewed_by), '') IS NOT NULL
            AND reviewed_on IS NOT NULL
        )
    )
);

COMMIT;
