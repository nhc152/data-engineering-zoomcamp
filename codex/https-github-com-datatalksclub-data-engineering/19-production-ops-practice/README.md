# Production Operations Practice Lab

## Goal

Practice operating Data Engineering pipelines after deployment: SLA, freshness, run metadata, runbooks, backfills, incidents, alerts, publish gates, and postmortems.

This lab is operations-first. It teaches how a production data pipeline survives failures, not just how it runs once.

## Target Operational Architecture

```text
data pipeline
  -> run metadata
  -> quality checks
  -> publish gate
  -> freshness/SLA monitor
  -> alerts
  -> runbook
  -> incident/postmortem process
```

## What This Lab Teaches

- SLA, SLO, SLI design.
- Freshness monitoring.
- Run metadata schema.
- Actionable runbooks.
- Incident severity.
- Backfill operations.
- Retry storm prevention.
- Postmortems.
- Publish gates.
- Cost and safety checks during reprocessing.

## Folder Structure

```text
19-production-ops-practice/
  README.md
  metadata/
  runbooks/
  incidents/
  alerts/
  backfill/
  publish-gates/
  exercises/
  solutions/
  templates/
```

## Learning Order

1. Read `metadata/run_metadata_schema.sql`.
2. Read `metadata/sla_slo_catalog.md`.
3. Read `publish-gates/publish_gate_design.md`.
4. Read runbooks in `runbooks/`.
5. Work through exercises.
6. Review incident scenarios.
7. Compare with solutions.

## Production Mental Model

A production pipeline is not production-ready because it is scheduled. It is production-ready when it is:

- observable
- debuggable
- recoverable
- idempotent
- cost-aware
- owner-aware
- documented
- protected by publish gates

## Pipeline Used In This Lab

Assume an ecommerce analytics pipeline:

```text
orders API / files
  -> raw orders
  -> staging orders
  -> fct_orders
  -> mart_daily_revenue
  -> finance dashboard
```

SLA:

```text
mart_daily_revenue must be published by 07:00 Asia/Saigon every day
for previous business day data.
```

Core quality expectations:

- Source freshness < 24 hours.
- Duplicate `order_id` = 0.
- Revenue reconciliation difference < 0.1%.
- Row count not lower than 70% of trailing 7-day median unless approved.

## Severity Model

| Severity | Meaning | Example | Response |
|---|---|---|---|
| SEV1 | Business-critical data wrong/unavailable | Finance revenue dashboard wrong before board report | Immediate owner response, status updates, postmortem |
| SEV2 | Important data delayed or partially wrong | Daily mart late by 2 hours | Same-day fix, incident note |
| SEV3 | Non-critical issue or limited blast radius | One non-critical dimension stale | Fix in normal priority |
| SEV4 | Cosmetic/doc/minor alert issue | Alert text missing link | Backlog |

## GitHub Deliverables

By the end, your repo should include:

- Run metadata schema.
- SLA/SLO catalog.
- Alert templates.
- Runbooks.
- Backfill plan.
- Publish gate design.
- Incident writeups.
- Postmortem template.

