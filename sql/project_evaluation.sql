-- One row per worksheet question and source record. Use question_id and project_id to filter.
-- F3 and F4 follow the expanded research scripts. The original worksheet
-- used F3 for the financial conclusion now filed under F4.
CREATE OR REPLACE VIEW analytics.project_evaluation AS
WITH questions(question_id, section, question) AS (
    VALUES
        ('S1', 'Stability', 'Approvals and compliance'),
        ('S2', 'Stability', 'Ownership and follow-up records'),
        ('F1', 'Profitability', 'Investment and costs'),
        ('F2', 'Profitability', 'Funding and participants'),
        ('F3', 'Profitability', 'Payment history and present value'),
        ('F4', 'Profitability', 'Financial outlook and exposure'),
        ('L1', 'Longevity', 'Stage and milestones'),
        ('L2', 'Longevity', 'Operations and maintenance'),
        ('L3', 'Longevity', 'Long-term availability'),
        ('V1', 'Feasibility', 'Demand and use'),
        ('V2', 'Feasibility', 'Capability gaps'),
        ('V3', 'Feasibility', 'Evidence for alternative solutions'),
        ('O1', 'Opportunities', 'Pain points'),
        ('O2', 'Opportunities', 'Service and value hypotheses'),
        ('O3', 'Opportunities', 'Buyer and procurement validation'),
        ('O4', 'Opportunities', 'Fee and delivery effort validation')
),
-- Route existing research records using the selections in the evidence scripts.
-- IDs in the register are global. New claims need a relevance review before
-- adding them to the ID selections below.
claim_rows AS (
    SELECT c.*, q.question_id
    FROM analytics.claim_evidence AS c
    CROSS JOIN LATERAL (
        VALUES
            ('S1', c.claim_id IN ('F07','F09','F18','F19','F23','F28','F36')),
            ('S2', c.claim_id IN ('F07','F09','F14','F18','F19','F23','F28','F36')),
            ('F1', c.claim_id IN ('F03','F06','F08','F10','F11','F12','F13','F14','F15','F16','F20','F25','F26','F27','F31')),
            ('F2', c.claim_id IN ('F07','F08','F10','F12','F14','F15','F19','F23','F25','F26','F31','F32')),
            ('F3', c.claim_type IN ('investment_plan','procurement','contract_scope','cost_estimate')
                OR c.research_statement ~* '(payroll|payout|remunerat|salary|paid|payment|disburs|cash.flow|NPV|present value|fund|revenue|settle|expenditure)'),
            ('F4', c.claim_id IN ('F03','F07','F08','F09','F10','F13','F14','F15','F18','F19','F22','F23','F24','F25','F28','F29','F30','F31','F36')),
            ('L1', c.claim_id IN ('F03','F06','F07','F09','F17','F18','F19','F23','F25','F28','F29','F30')),
            ('L2', c.claim_id IN ('F11','F12','F13','F14','F18','F19','F25','F28','F31','F32')),
            ('L3', c.claim_id IN ('F06','F13','F19','F20','F21','F22','F25','F28','F29','F36')),
            ('V1', c.claim_id IN ('F03','F04','F07','F09','F16','F22','F23','F24','F28','F29','F30')
                OR c.research_statement ~* '(commitment|paid.*(volum|order)|shipper contract|metered sales|actual throughput|delivery log)'),
            ('V2', c.claim_id IN ('F06','F07','F09','F11','F14','F18','F19','F23','F28','F29','F30','F36')),
            ('V3', c.claim_id IN ('F03','F06','F07','F13','F18','F19','F22','F23','F28','F29','F30','F36'))
    ) AS q(question_id, matches)
    WHERE q.matches
),
metric_rows AS (
    SELECT m.*, q.question_id
    FROM analytics.project_metrics AS m
    CROSS JOIN LATERAL (
        VALUES
            ('F1', m.unit_standardized ILIKE 'CNY%'),
            ('F3', m.unit_standardized ILIKE 'CNY%'),
            ('V1', m.claim_id IN ('F03','F04','F16','F22','F28','F29','F30'))
    ) AS q(question_id, matches)
    WHERE q.matches
),
organization_rows AS (
    SELECT o.*, q.question_id
    FROM analytics.organization_involvement AS o
    CROSS JOIN LATERAL (
        VALUES
            ('S2', o.mention_id IN ('R003','R007','R008','R010','R011','R012','R013','R017')),
            ('F2', o.mention_id IN ('R001','R002','R003','R007','R008','R011','R012','R015')),
            ('F3', o.mention_id IN ('R003','R004','R005','R007','R009','R011','R012')),
            ('F4', o.mention_id IN ('R003','R004','R005','R007','R009','R011','R012','R013')),
            ('L2', true),
            ('V2', o.mention_id IN ('R003','R004','R005','R007','R008','R009','R010','R011','R012','R013'))
    ) AS q(question_id, matches)
    WHERE q.matches
),
commercial_rows AS (
    SELECT c.*, q.question_id
    FROM analytics.commercial_research AS c
    CROSS JOIN LATERAL (
        VALUES
            ('F4', c.record_id IN ('PP01','PP02','PP03','PP04','PP05','PP07','PP08','PP10')),
            ('L2', c.record_id = 'PP03'),
            ('L3', c.record_id IN ('PP02','PP03','PP05','PP06','PP08','PP09','PP10')),
            ('V1', c.record_id IN ('PP01','PP04','PP07','PP10')),
            ('V2', c.record_id IN ('PP02','PP05','PP06','PP08','PP09')),
            ('O1', c.record_type = 'pain_point'),
            ('O2', c.record_type = 'opportunity'),
            ('O3', c.record_type = 'opportunity'),
            ('O4', c.record_type = 'opportunity')
    ) AS q(question_id, matches)
    WHERE q.matches
),
evidence (
    question_id, project_id, record_type, record_id, finding,
    evidence_status, measurement_status, review_status, organization,
    amount, unit, record_date, date_meaning, notes, related_claim_id,
    client_validation_required, client_budget_known, client_purchase_intent_known,
    source_ids, source_urls
) AS (
    SELECT question_id, project_id, 'claim', claim_id, research_statement,
           evidence_status, measurement_status, review_status, NULL::text,
           reported_numeric_value::numeric, unit_standardized,
           source_published_date::text, 'source publication', NULL::text, NULL::text,
           NULL::text, NULL::text, NULL::text, source_id, source_url
    FROM claim_rows

    UNION ALL

    SELECT question_id, project_id, 'metric', metric_id, metric_description,
           evidence_status, measurement_status, review_status, NULL,
           metric_value::numeric, unit_standardized,
           source_published_date::text, 'source publication', NULL, claim_id,
           NULL, NULL, NULL, source_id, source_url
    FROM metric_rows

    UNION ALL

    SELECT question_id, project_id, 'reported role', mention_id, reported_role,
           relationship_evidence_status, NULL, NULL, organization_name,
           NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, source_id, source_url
    FROM organization_rows

    UNION ALL

    SELECT 'S2', r.project_id, 'reviewed role', r.org_id::text, r.role_type,
           NULL, NULL, r.current_status, o.organization_name,
           NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, r.evidence_source_id, s.url
    FROM core.project_organizations AS r
    JOIN core.organizations AS o USING (org_id)
    LEFT JOIN core.sources AS s ON s.source_id = r.evidence_source_id

    UNION ALL

    SELECT q.question_id, t.project_id, t.record_type, t.record_id, t.description,
           t.record_status, NULL, NULL, NULL,
           NULL, NULL, t.date_as_reported, t.date_meaning, t.qualification, NULL,
           NULL, NULL, NULL, t.source_id, t.source_url
    FROM analytics.project_timeline AS t
    CROSS JOIN LATERAL (
        VALUES ('L1', true), ('V3', t.record_type = 'observation')
    ) AS q(question_id, matches)
    WHERE q.matches

    UNION ALL

    SELECT question_id, project_id, record_type, record_id, research_item,
           evidence_status, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, research_note, NULL,
           client_validation_required::text, client_budget_known,
           client_purchase_intent_known, source_ids, source_urls
    FROM commercial_rows

    UNION ALL

    SELECT 'F2', research_project_id, 'source reference', source_id, title,
           NULL, NULL, NULL, NULL,
           NULL, NULL, published_date_exact::text, 'source publication', publisher, NULL,
           NULL, NULL, NULL, source_id, url
    FROM core.sources
)
SELECT q.section, q.question_id, q.question, e.project_id, p.project_name,
       e.finding, e.record_type, e.evidence_status, e.measurement_status,
       e.amount, e.unit, e.record_date, e.date_meaning, e.organization,
       e.notes, e.client_validation_required, e.client_budget_known,
       e.client_purchase_intent_known, e.source_urls, e.record_id,
       e.related_claim_id, e.source_ids, e.review_status
FROM evidence AS e
JOIN questions AS q USING (question_id)
LEFT JOIN analytics.project_overview AS p USING (project_id)
WHERE e.project_id IN ('PRJ001', 'PRJ002', 'PRJ003');

COMMENT ON VIEW analytics.project_evaluation IS
    'Research Intelligence worksheet evidence for PRJ001–PRJ003. Filter on question_id and project_id. A record can inform several questions.';
COMMENT ON COLUMN analytics.project_evaluation.record_date IS
    'Date as shown in the source record. Use date_meaning to tell publication dates, snapshots, occurrence dates and forecasts apart.';
COMMENT ON COLUMN analytics.project_evaluation.evidence_status IS
    'Source or register status, interpreted with record_type, measurement_status and review_status. NULL means this record does not supply that status.';
COMMENT ON COLUMN analytics.project_evaluation.amount IS
    'Value in the stated unit. Claim and metric rows can describe the same figure. Check record_type, related_claim_id and measurement_status before aggregating.';
