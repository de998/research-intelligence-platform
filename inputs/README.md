# Input files

These CSVs are import templates and test fixtures used by the SQL maintenance
scripts.

- `phase3f_identity_test.csv` and `phase3f_status_test.csv` contain synthetic
  test records for the rollback-only integration test.
- `phase7_assessments.csv`, `phase7_relationship_decisions.csv`,
  `organization_identity_decisions.csv`, `project_org_status_decisions.csv`,
  `project_events.csv`, and `project_network_decisions.csv` are templates.
- The populated project-network decisions from the original working package
  are intentionally not included.

Run the relevant `psql` scripts from the repository root because their `\copy`
commands use paths relative to the current working directory.
