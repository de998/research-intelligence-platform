SELECT
    m.incoming_org_id,
    m.canonical_org_id
FROM {{ ref('organization_identity_map') }} m
JOIN {{ ref('organization_identity_map') }} target
    ON m.canonical_org_id = target.incoming_org_id
WHERE target.canonical_org_id <> target.incoming_org_id
