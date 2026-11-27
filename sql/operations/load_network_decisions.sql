
BEGIN;

TRUNCATE TABLE raw.raw_project_network_decisions;

\copy raw.raw_project_network_decisions (project_id, network_id, relevance_type, classification_status, classification_rationale, source_id, reviewed_by, reviewed_at) FROM 'inputs/project_network_decisions.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

COMMIT;
