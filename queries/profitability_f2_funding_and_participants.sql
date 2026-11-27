-- Run read-only in DBeaver against Research Intelligence PostgreSQL (research_demo).
-- F2: compare funding disclosures, reported participants, and source documents.

SELECT project_id, claim_id, research_statement, reported_numeric_value,
       unit_standardized, measurement_status, evidence_status, review_status,
       source_id, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F07'), ('PRJ001', 'F08'), ('PRJ001', 'F10'), ('PRJ001', 'F12'),
    ('PRJ002', 'F14'), ('PRJ002', 'F15'), ('PRJ002', 'F19'), ('PRJ002', 'F23'),
    ('PRJ003', 'F25'), ('PRJ003', 'F26'), ('PRJ003', 'F31'), ('PRJ003', 'F32')
)
ORDER BY project_id, claim_id;

SELECT project_id, mention_id, organization_name, reported_role,
       relationship_evidence_status, source_id, source_url
FROM analytics.organization_involvement
WHERE mention_id IN ('R001', 'R002', 'R003', 'R007', 'R008', 'R011', 'R012', 'R015')
ORDER BY project_id, mention_id;

SELECT research_project_id AS project_id, source_id, publisher, title, url
FROM core.sources
WHERE research_project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
ORDER BY research_project_id, source_id;
