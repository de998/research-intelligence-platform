# Data and release notes

## Included demonstration data

`data/demo/` contains selected source-derived extracts:

- sources
- projects
- organizations
- claims
- source-reported organization mentions

The records retain source URLs and access dates. They are a historical
demonstration extract, not a live feed and not independently audited by this
repository.

## Excluded from this portfolio copy

- The PostgreSQL custom-format database dump
- Database inventory and row-level verification fingerprints
- Live/local dbt connection profile
- The original Excel research register
- Analyst-authored pain-point and opportunity records
- Populated project-network classifications and other human decision history
- Old backup files and default dbt tutorial models

The analyst-authored hypotheses and decision records are not simply scraped
facts. They may represent employer-owned research or commercial work, so they
are not included in this release candidate.

## Reproducibility limitation

The original database snapshot includes table definitions and stored records.
That dump is intentionally not distributed here. The repository does not yet
contain a complete clean-room bootstrap of every RAW table. A user needs a
separately provisioned development database with the expected source tables
before running the dbt models.

## Before making the repository public

1. Confirm ownership and company permission for the code, architecture,
   research methodology, and any remaining data.
2. Check the terms of the source websites and any applicable database rights.
3. Confirm that no confidential research, client information, or personal
   information has been added.
4. Review all commits and repository history, not only the current files.
5. Add a license only after the rights holder has chosen one.
