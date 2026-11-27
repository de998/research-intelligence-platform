
BEGIN;

CREATE TABLE IF NOT EXISTS raw.raw_project_observations (
    observation_id TEXT PRIMARY KEY,
    project_id TEXT NOT NULL,
    source_id TEXT NOT NULL,
    source_url TEXT,
    observed_project_stage TEXT NOT NULL,
    as_of_date_raw TEXT,
    as_of_date_exact DATE NOT NULL,
    review_note TEXT,
    imported_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Preserve our three existing project snapshots.
-- ON CONFLICT prevents duplicate baseline imports.

INSERT INTO raw.raw_project_observations (
    observation_id,
    project_id,
    source_id,
    source_url,
    observed_project_stage,
    as_of_date_raw,
    as_of_date_exact,
    review_note
)
SELECT
    'OBS:BASELINE:' || project_id,
    project_id,
    source_id,
    source_url,
    observed_project_stage,
    as_of_date_raw,
    as_of_date_exact,
    review_note
FROM core.stg_projects
WHERE as_of_date_exact IS NOT NULL
  AND NULLIF(BTRIM(observed_project_stage), '') IS NOT NULL
ON CONFLICT (observation_id) DO NOTHING;

COMMIT;

SELECT
    observation_id,
    project_id,
    as_of_date_exact,
    observed_project_stage
FROM raw.raw_project_observations
ORDER BY project_id, as_of_date_exact;
