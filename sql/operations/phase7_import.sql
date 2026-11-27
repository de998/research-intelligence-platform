
\set ON_ERROR_STOP on

BEGIN;

SELECT pg_advisory_xact_lock(
    hashtext('research_intelligence_phase7_import')
);

CREATE TEMP TABLE incoming_assessments (
    LIKE raw.raw_research_assessments INCLUDING DEFAULTS
) ON COMMIT DROP;

CREATE TEMP TABLE incoming_relationship_decisions (
    LIKE raw.raw_pain_point_opportunity_decisions
    INCLUDING DEFAULTS
) ON COMMIT DROP;

\copy incoming_assessments (assessment_id,record_type,record_id,assessment_outcome,analysis_text,evidence_source_id,strategic_fit_score,demand_score,feasibility_score,evidence_score,analyst_name,assessed_on) FROM 'inputs/phase7_assessments.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

\copy incoming_relationship_decisions (decision_id,pain_point_id,opportunity_id,decision_outcome,rationale,evidence_source_id,reviewer_name,decided_on) FROM 'inputs/phase7_relationship_decisions.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

DO $$
BEGIN

    -- Reject duplicate IDs inside either CSV.

    IF EXISTS (
        SELECT assessment_id
        FROM incoming_assessments
        GROUP BY assessment_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicate assessment IDs in CSV';
    END IF;

    IF EXISTS (
        SELECT decision_id
        FROM incoming_relationship_decisions
        GROUP BY decision_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicate relationship decision IDs in CSV';
    END IF;

    -- Verify subject records and evidence source IDs.

    IF EXISTS (
        SELECT 1
        FROM incoming_assessments i
        LEFT JOIN core.projects p
            ON i.record_type = 'project'
           AND i.record_id = p.project_id
        LEFT JOIN core.pain_points pp
            ON i.record_type = 'pain_point'
           AND i.record_id = pp.pain_point_id
        LEFT JOIN core.opportunities o
            ON i.record_type = 'opportunity'
           AND i.record_id = o.opportunity_id
        LEFT JOIN core.sources s
            ON i.evidence_source_id = s.source_id
        WHERE s.source_id IS NULL
           OR (
               p.project_id IS NULL
               AND pp.pain_point_id IS NULL
               AND o.opportunity_id IS NULL
           )
    ) THEN
        RAISE EXCEPTION
            'Assessment references an unknown subject or source';
    END IF;

    -- Verify that a relationship connects records
    -- belonging to the same project.

    IF EXISTS (
        SELECT 1
        FROM incoming_relationship_decisions i
        LEFT JOIN core.pain_points p
            ON i.pain_point_id = p.pain_point_id
        LEFT JOIN core.opportunities o
            ON i.opportunity_id = o.opportunity_id
        LEFT JOIN core.sources s
            ON i.evidence_source_id = s.source_id
        WHERE p.pain_point_id IS NULL
           OR o.opportunity_id IS NULL
           OR s.source_id IS NULL
           OR p.project_id IS DISTINCT FROM o.project_id
    ) THEN
        RAISE EXCEPTION
            'Relationship has invalid IDs or crosses projects';
    END IF;

    -- Prevent silent rewriting of existing assessments.

    IF EXISTS (
        SELECT 1
        FROM incoming_assessments i
        JOIN raw.raw_research_assessments a
            ON i.assessment_id = a.assessment_id
        WHERE
            (to_jsonb(i) - 'imported_at')
            IS DISTINCT FROM
            (to_jsonb(a) - 'imported_at')
    ) THEN
        RAISE EXCEPTION
            'Existing assessment ID was modified';
    END IF;

    -- Prevent silent rewriting of relationship decisions.

    IF EXISTS (
        SELECT 1
        FROM incoming_relationship_decisions i
        JOIN raw.raw_pain_point_opportunity_decisions d
            ON i.decision_id = d.decision_id
        WHERE
            (to_jsonb(i) - 'imported_at')
            IS DISTINCT FROM
            (to_jsonb(d) - 'imported_at')
    ) THEN
        RAISE EXCEPTION
            'Existing relationship decision ID was modified';
    END IF;

END
$$;

-- Append only new assessments.

INSERT INTO raw.raw_research_assessments (
    assessment_id,
    record_type,
    record_id,
    assessment_outcome,
    analysis_text,
    evidence_source_id,
    strategic_fit_score,
    demand_score,
    feasibility_score,
    evidence_score,
    analyst_name,
    assessed_on
)
SELECT
    assessment_id,
    record_type,
    record_id,
    assessment_outcome,
    analysis_text,
    evidence_source_id,
    strategic_fit_score,
    demand_score,
    feasibility_score,
    evidence_score,
    analyst_name,
    assessed_on
FROM incoming_assessments
ON CONFLICT (assessment_id) DO NOTHING;

-- Append only new relationship decisions.

INSERT INTO raw.raw_pain_point_opportunity_decisions (
    decision_id,
    pain_point_id,
    opportunity_id,
    decision_outcome,
    rationale,
    evidence_source_id,
    reviewer_name,
    decided_on
)
SELECT
    decision_id,
    pain_point_id,
    opportunity_id,
    decision_outcome,
    rationale,
    evidence_source_id,
    reviewer_name,
    decided_on
FROM incoming_relationship_decisions
ON CONFLICT (decision_id) DO NOTHING;

COMMIT;

SELECT
    (SELECT COUNT(*)
     FROM raw.raw_research_assessments)
        AS total_assessments,

    (SELECT COUNT(*)
     FROM raw.raw_pain_point_opportunity_decisions)
        AS total_relationship_decisions;
