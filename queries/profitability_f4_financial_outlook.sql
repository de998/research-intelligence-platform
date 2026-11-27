-- Run read-only in the local Research Intelligence PostgreSQL database (research_demo).
-- F4: compare financial evidence, V1 demand signals, and documented responsibilities.

SELECT project_id, claim_id, research_statement, reported_numeric_value,
       unit_standardized, measurement_status, evidence_status, source_id, source_url
FROM analytics.claim_evidence
WHERE (project_id, claim_id) IN (
    ('PRJ001', 'F03'), ('PRJ001', 'F07'), ('PRJ001', 'F08'), ('PRJ001', 'F09'),
    ('PRJ001', 'F10'), ('PRJ001', 'F13'),
    ('PRJ002', 'F14'), ('PRJ002', 'F15'), ('PRJ002', 'F18'), ('PRJ002', 'F19'),
    ('PRJ002', 'F22'), ('PRJ002', 'F23'), ('PRJ002', 'F24'),
    ('PRJ003', 'F25'), ('PRJ003', 'F28'), ('PRJ003', 'F29'), ('PRJ003', 'F30'),
    ('PRJ003', 'F31'), ('PRJ003', 'F36')
)
ORDER BY project_id, claim_id;

SELECT project_id, record_id, research_item, evidence_status,
       client_validation_required, source_ids, source_urls
FROM analytics.commercial_research
WHERE record_id IN ('PP01', 'PP02', 'PP03', 'PP04', 'PP05', 'PP07', 'PP08', 'PP10')
ORDER BY project_id, record_id;

SELECT project_id, mention_id, organization_name, reported_role,
       relationship_evidence_status, source_id, source_url
FROM analytics.organization_involvement
WHERE mention_id IN ('R003', 'R004', 'R005', 'R007', 'R009', 'R011', 'R012', 'R013')
ORDER BY project_id, mention_id;
