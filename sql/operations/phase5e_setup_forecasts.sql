
\set ON_ERROR_STOP on

BEGIN;

CREATE TABLE IF NOT EXISTS raw.raw_event_forecasts (
    forecast_id TEXT PRIMARY KEY,
    project_id TEXT NOT NULL,
    source_id TEXT NOT NULL,

    milestone_key TEXT NOT NULL,
    forecast_statement TEXT NOT NULL,

    target_date_raw TEXT,
    target_date_precision TEXT NOT NULL
        CHECK (
            target_date_precision IN
            ('day', 'month', 'year', 'unknown')
        ),

    target_date_exact DATE,
    target_year INTEGER,
    target_month INTEGER,

    review_status TEXT NOT NULL DEFAULT 'proposed'
        CHECK (review_status IN ('proposed', 'verified')),

    reviewed_by TEXT,
    reviewed_on DATE,

    imported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT forecast_date_consistency CHECK (
        (
            target_date_precision = 'day'
            AND target_date_exact IS NOT NULL
            AND target_year IS NULL
            AND target_month IS NULL
        )
        OR
        (
            target_date_precision = 'month'
            AND target_date_exact IS NULL
            AND target_year BETWEEN 1 AND 9999
            AND target_month BETWEEN 1 AND 12
        )
        OR
        (
            target_date_precision = 'year'
            AND target_date_exact IS NULL
            AND target_year BETWEEN 1 AND 9999
            AND target_month IS NULL
        )
        OR
        (
            target_date_precision = 'unknown'
            AND target_date_exact IS NULL
            AND target_year IS NULL
            AND target_month IS NULL
        )
    ),

    CONSTRAINT verified_forecast_requires_review CHECK (
        review_status <> 'verified'
        OR (
            NULLIF(BTRIM(reviewed_by), '') IS NOT NULL
            AND reviewed_on IS NOT NULL
        )
    )
);

COMMIT;
