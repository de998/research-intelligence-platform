# Evidence-First Research Intelligence Platform

A PostgreSQL and dbt project for turning fragmented public-source research into
traceable claims, normalized project and organization records, structured
evidence reviews, timelines, and analyst-facing datasets.

This repository is a **portfolio demonstration**, not a production deployment
or a complete database backup.

## What it demonstrates

- PostgreSQL data modelling across RAW, CORE, and ANALYTICS layers
- dbt staging transformations, macros, model documentation, and data tests
- Source provenance: source IDs, URLs, publication dates, and access dates
- Evidence-aware handling of claims, measurements, plans, observations, and
  forecasts
- Organization identity and project-role history
- Review queues that expose unresolved evidence rather than hiding uncertainty
- Human-authored assessments and explicit relationship decisions
- Analyst-facing views with documented row grain and example queries

## Architecture

```text
Public-source records and reviewed inputs
                  |
                  v
              RAW layer
     source-aligned input tables
                  |
                  v
            STAGING layer
   normalized IDs, dates, text, units
                  |
                  v
              CORE layer
 entities, claims, metrics, relationships,
 timelines, review queues, human decisions
                  |
                  v
           ANALYTICS layer
  query-ready views and research worksheets
```

The original database snapshot associated with this project contained 17 RAW
tables, 12 CORE tables, 34 CORE views, and 23 ANALYTICS views. The snapshot is
not included in this repository.

## Design principles

1. Preserve links from analytical records to their source material.
2. Keep a published claim distinct from its measurement status and review
   status.
3. Distinguish research snapshots, reported events, and forecasts.
4. Treat missing information as unknown, not as evidence of low risk.
5. Keep pain points and service opportunities separate unless a human reviewer
   explicitly approves a relationship.
6. Do not infer that two records are related merely because they share a
   project ID.

## Repository layout

- `models/` — dbt staging and CORE models, model documentation, and tests
- `macros/` — reusable SQL/Jinja normalization helpers
- `sql/` — analytics view builds and operational SQL
- `queries/` — example research and analyst queries
- `data/demo/` — selected source-derived CSV extracts with source URLs
- `data/templates/` — header-only templates for analyst-authored datasets
- `inputs/` — human-decision import templates and synthetic test fixtures
- `docs/` — architecture, methodology, and release notes
- `scripts/` — guarded macOS/Linux refresh helper

## Technology

- PostgreSQL
- dbt Core `1.12.6`
- dbt-postgres adapter `1.11.0`
- Python 3
- DBeaver or another PostgreSQL client for inspection

## Important: database setup is separate

The PostgreSQL dump from the original working environment is intentionally
excluded. This repository also does not include the original full RAW schema
DDL or private decision history. It is therefore **not a one-click restore**
from an empty PostgreSQL database.

To run the dbt project, you need a development database with the required
`raw` source tables already provisioned. The CSVs in `data/demo/` are
reference extracts; they are not automatically loaded by dbt.

## Local setup

1. Create and activate a Python virtual environment.
2. Install the direct dependencies:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   python -m pip install --upgrade pip
   pip install -r requirements.txt
   ```

3. Create your local dbt profile:

   ```bash
   mkdir -p ~/.dbt
   cp profiles.yml.example ~/.dbt/profiles.yml
   ```

4. Set the connection environment variables in your terminal. Use your own
   development database details:

   ```bash
   export PGHOST="localhost"
   export PGPORT="5432"
   export PGUSER="your_postgres_user"
   export PGDATABASE="research_demo"

   printf "PostgreSQL password: "
   read -s DBT_ENV_SECRET_RESEARCH_PASSWORD
   printf "\n"
   export DBT_ENV_SECRET_RESEARCH_PASSWORD
   export PGPASSWORD="$DBT_ENV_SECRET_RESEARCH_PASSWORD"
   ```

5. Confirm the connection and run dbt:

   ```bash
   dbt debug --profiles-dir ~/.dbt
   dbt run --profiles-dir ~/.dbt
   dbt test --profiles-dir ~/.dbt
   ```

6. Build the analyst-facing SQL views:

   ```bash
   psql -X -v ON_ERROR_STOP=1 -d "$PGDATABASE" -f sql/analytics_build.sql
   ```

These commands assume that the required RAW tables and their source data have
already been provisioned. Do not run them against a production database.

## Refresh helper

The macOS/Linux helper rebuilds dbt models, runs tests, and then rebuilds the
ANALYTICS views. It has a confirmation guard:

```bash
chmod +x scripts/refresh.sh
CONFIRM_REFRESH=YES scripts/refresh.sh
```

Use it only against a development/test database after confirming the target
and taking a backup.

## Research methodology

The included worksheet organizes evidence into five dimensions:

- Stability
- Profitability
- Longevity
- Feasibility and viability
- Commercial opportunities

The detailed questions and evidence routing are documented in
[`docs/research_methodology.md`](docs/research_methodology.md). The worksheet
contains case-specific claim and record identifiers; it should be reviewed
before reusing it for a different case.

## Data provenance and publication

The included CSV extracts retain source IDs and URLs. They are a historical
demonstration dataset, not independently audited facts. Analyst-generated
pain-point and opportunity hypotheses and populated human decision inputs
were excluded from this portfolio copy.

Public availability does not automatically grant permission to republish a
compiled dataset. Review publisher/site terms and obtain any required company
approval before changing this repository to public.

No software or data license is included. Do not assume that others have
permission to reuse the code or data unless a license is added by the rights
holder.
