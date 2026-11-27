-- Run in DBeaver against the local Research Intelligence PostgreSQL database (research_demo).
-- S2: compare reported roles, reviewed roles, and the milestone evidence.

SELECT project_id, mention_id, organization_name, reported_role,
       relationship_evidence_status, source_id, source_url
FROM analytics.organization_involvement
WHERE mention_id IN ('R003', 'R007', 'R008', 'R010', 'R011', 'R012', 'R013', 'R017')
ORDER BY project_id, mention_id;

SELECT project_role.project_id, organization.organization_name,
       project_role.role_type, project_role.current_status, project_role.evidence_source_id
FROM core.project_organizations AS project_role
JOIN core.organizations AS organization USING (org_id)
WHERE project_role.project_id IN ('PRJ001', 'PRJ002', 'PRJ003')
ORDER BY project_role.project_id, organization.organization_name, project_role.role_type;

SELECT project_id, claim_id, research_statement, measurement_status,
       evidence_status, review_status, source_id, source_published_date, source_url
FROM analytics.claim_evidence
WHERE claim_id IN ('F07', 'F09', 'F14', 'F18', 'F19', 'F23', 'F28', 'F36')
ORDER BY project_id, claim_id;
