#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="${DBT_PROFILES_DIR:-$HOME/.dbt}"

if [[ -z "${PGDATABASE:-}" ]]; then
  echo "Set PGDATABASE to the development database before running this script." >&2
  exit 2
fi

if [[ "${CONFIRM_REFRESH:-}" != "YES" ]]; then
  echo "This will rebuild dbt models, run tests, and replace analytics views in: ${PGDATABASE}" >&2
  echo "Only use it against a development/test database with a current backup." >&2
  echo "After checking the target, run: CONFIRM_REFRESH=YES scripts/refresh.sh" >&2
  exit 2
fi

command -v dbt >/dev/null 2>&1 || { echo "dbt was not found on PATH." >&2; exit 127; }
command -v psql >/dev/null 2>&1 || { echo "psql was not found on PATH." >&2; exit 127; }

cd "$PROJECT_ROOT"

dbt debug --profiles-dir "$PROFILE_DIR"
dbt run --profiles-dir "$PROFILE_DIR"
dbt test --profiles-dir "$PROFILE_DIR"

psql -X -v ON_ERROR_STOP=1 -d "$PGDATABASE" -f "$PROJECT_ROOT/sql/analytics_build.sql"

echo "Refresh completed for database: ${PGDATABASE}"
