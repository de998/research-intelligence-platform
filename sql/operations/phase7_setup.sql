
\set ON_ERROR_STOP on

BEGIN;

-- Register 1: Analyst assessments of projects,
-- pain points and opportunities.

CREATE TABLE IF NOT EXISTS raw.raw_research_assessments (
    assessment_id TEXT PRIMARY KEY,

    record_type TEXT NOT NULL CHECK (
        record_type IN ('project', 'pain_point', 'opportunity')
    ),
    record_id TEXT NOT NULL,

    assessment_outcome TEXT NOT NULL CHECK (
        assessment_outcome IN (
            'positive', 'negative', 'undetermined'
        )
    ),

    analysis_text TEXT NOT NULL CHECK (
        LENGTH(BTRIM(analysis_text)) > 0
    ),

    evidence_source_id TEXT NOT NULL,

    strategic_fit_score SMALLINT CHECK (
        strategic_fit_score BETWEEN 0 AND 5
    ),
    demand_score SMALLINT CHECK (
        demand_score BETWEEN 0 AND 5
    ),
    feasibility_score SMALLINT CHECK (
        feasibility_score BETWEEN 0 AND 5
    ),
    evidence_score SMALLINT CHECK (
        evidence_score BETWEEN 0 AND 5
    ),

    analyst_name TEXT NOT NULL CHECK (
        LENGTH(BTRIM(analyst_name)) > 0
    ),
    assessed_on DATE NOT NULL,

    imported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT scores_only_for_opportunities CHECK (
        record_type = 'opportunity'
        OR (
            strategic_fit_score IS NULL
            AND demand_score IS NULL
            AND feasibility_score IS NULL
            AND evidence_score IS NULL
        )
    ),

    CONSTRAINT complete_score_or_no_score CHECK (
        (
            strategic_fit_score IS NULL
            AND demand_score IS NULL
            AND feasibility_score IS NULL
            AND evidence_score IS NULL
        )
        OR
        (
            strategic_fit_score IS NOT NULL
            AND demand_score IS NOT NULL
            AND feasibility_score IS NOT NULL
            AND evidence_score IS NOT NULL
        )
    )
);

-- Register 2: Explicit human decisions on whether
-- a pain point is related to an opportunity.

CREATE TABLE IF NOT EXISTS
raw.raw_pain_point_opportunity_decisions (
    decision_id TEXT PRIMARY KEY,

    pain_point_id TEXT NOT NULL,
    opportunity_id TEXT NOT NULL,

    decision_outcome TEXT NOT NULL CHECK (
        decision_outcome IN (
            'approved',
            'rejected',
            'needs_more_evidence'
        )
    ),

    rationale TEXT NOT NULL CHECK (
        LENGTH(BTRIM(rationale)) > 0
    ),

    evidence_source_id TEXT NOT NULL,

    reviewer_name TEXT NOT NULL CHECK (
        LENGTH(BTRIM(reviewer_name)) > 0
    ),
    decided_on DATE NOT NULL,

    imported_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMIT;
