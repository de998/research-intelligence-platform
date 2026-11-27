-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- L2: check documented operations and maintenance scope and the roles of named organizations.

SELECT project_id, claim_id, research_statement, measurement_status,
       evidence_status, source_id, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F11'), ('PRJ001', 'F12'), ('PRJ001', 'F13'),
    ('PRJ002', 'F14'), ('PRJ002', 'F18'), ('PRJ002', 'F19'),
    ('PRJ003', 'F25'), ('PRJ003', 'F28'), ('PRJ003', 'F31'), ('PRJ003', 'F32')
)
ORDER BY project_id, claim_id;

SELECT project_id, mention_id, organization_name, reported_role,
       relationship_evidence_status, source_id, source_url
FROM analytics.organization_involvement
WHERE project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
ORDER BY project_id, mention_id;

SELECT project_id, record_id, research_item, evidence_status,
       client_validation_required, source_ids, source_urls
FROM analytics.commercial_research
WHERE record_id = 'PP03'
ORDER BY project_id, record_id;
