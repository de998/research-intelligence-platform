# Architecture

## Layer responsibilities

### RAW

The RAW layer stores source-aligned records and human-input tables. The
demonstration schema includes source records, projects, organizations, claims,
organization mentions, pain points, opportunities, project observations,
events, forecasts, network decisions, and human review inputs.

RAW fields preserve original identifiers and source references so downstream
transformations do not erase provenance.

### STAGING

The staging models normalize identifiers, text, categories, dates, units, and
empty values. Date handling preserves both the value as reported and the
normalized/validated date where applicable.

Staging is the boundary between source-shaped input and normalized CORE
entities.

### CORE

The CORE layer contains normalized projects, sources, organizations, claims,
metrics, networks, organization identity resolution, organization/project
relationship history, project observations, events, forecasts, and evidence
review queues.

Human assessments and explicit relationship decisions are stored as input
records and exposed through history/current-state models. The design does not
automatically connect a pain point to an opportunity based only on a shared
project ID.

### ANALYTICS

The ANALYTICS layer exposes query-ready views.

`analytics_build.sql` creates the foundational catalog, project overview,
claim evidence, metrics, organization involvement, timeline, commercial
research, and research-gap views. It then includes the project evaluation
worksheet and the analyst-facing views.

The analyst-facing views provide narrower datasets for projects, sources,
claims, metrics, timelines, organizations, project roles, networks, pain
points, opportunities, opportunity sources, approved opportunity/pain-point
relationships, review queues, and navigation.

## Evidence semantics

Interpret these fields together rather than treating them as interchangeable:

- `evidence_status` — how the source or record is classified
- `measurement_status` — whether a number is reported, planned, estimated, or
  otherwise qualified
- `review_status` — whether a record has been reviewed or remains pending
- source ID and URL — where the record can be checked

A cited source is a reference to inspect; its inclusion does not prove that it
supports every associated analytical interpretation.

## Timeline semantics

The timeline distinguishes a research snapshot from a reported event and a
forecast. The date meaning and precision must be read before interpreting a
timeline date as an occurrence date.

## Snapshot scope

The migration inventory dated 2026-11-24 recorded 17 RAW tables, 12 CORE
tables, 34 CORE views, and 23 ANALYTICS views. The corresponding PostgreSQL
backup and internal verification fingerprints are not part of this portfolio
repository.
