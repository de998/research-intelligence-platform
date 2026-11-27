-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- V2: compare next-phase dependencies with documented delivery and coordination roles.

SELECT project_id, claim_id, research_statement, measurement_status,
       evidence_status, source_id, source_published_date, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F06'), ('PRJ001', 'F07'), ('PRJ001', 'F09'), ('PRJ001', 'F11'),
    ('PRJ002', 'F14'), ('PRJ002', 'F18'), ('PRJ002', 'F19'), ('PRJ002', 'F23'),
    ('PRJ003', 'F28'), ('PRJ003', 'F29'), ('PRJ003', 'F30'), ('PRJ003', 'F36')
)
ORDER BY project_id, claim_id;

SELECT project_id, record_id, research_item, evidence_status,
       client_validation_required, source_ids, source_urls
FROM analytics.commercial_research
WHERE record_id IN ('PP02', 'PP05', 'PP06', 'PP08', 'PP09')
ORDER BY project_id, record_id;

SELECT project_id, mention_id, organization_name, reported_role,
       relationship_evidence_status, source_id, source_url
FROM analytics.organization_involvement
WHERE mention_id IN ('R003', 'R004', 'R005', 'R007', 'R008', 'R009', 'R010',
                     'R011', 'R012', 'R013')
ORDER BY project_id, mention_id;
