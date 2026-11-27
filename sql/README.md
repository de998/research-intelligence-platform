# SQL scripts

## Analytics build

After the dbt models have been built successfully, run:

```bash
psql -X -v ON_ERROR_STOP=1 -d "$PGDATABASE" -f sql/analytics_build.sql
```

`analytics_build.sql` creates the foundational analyst views and includes
`project_evaluation.sql` and `analyst_views.sql` using psql's `\\ir` command.

## Operational scripts

The scripts in `operations/` support event, forecast, identity, network, and
human-assessment workflows. They assume the matching RAW/CORE schema already
exists.

Run them from the repository root, for example:

```bash
psql -X -v ON_ERROR_STOP=1 -d "$PGDATABASE" -f sql/operations/phase7_setup.sql
psql -X -v ON_ERROR_STOP=1 -d "$PGDATABASE" -f sql/operations/phase7_import.sql
```

The CSV paths used by `\\copy` are relative to the current working directory.
Do not run import scripts against production without reviewing their effects
and taking a backup. In particular, `load_network_decisions.sql` truncates
`raw.raw_project_network_decisions` before reloading it.
