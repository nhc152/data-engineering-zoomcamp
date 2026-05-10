# Data Quality Practice Lab

## Goal

Practice data quality, observability, alerting, and incident response like a Data Reliability Engineer.

This lab is SQL-first. The SQL is written in a mostly PostgreSQL-compatible style, but the checks are portable to BigQuery/dbt with small syntax changes.

Target flow:

```text
raw layer
  -> staging layer
  -> marts/facts
  -> data quality checks
  -> alerts
  -> incident response
  -> prevention
```

## What You Will Learn

- Freshness checks.
- Completeness and volume checks.
- Uniqueness checks.
- Validity and accepted values checks.
- Referential integrity checks.
- Reconciliation checks.
- Anomaly thresholds.
- Alert design with owner, impact, and runbook.
- Incident notes with root cause and prevention.
- Cost-aware quality checks.

## Folder Structure

```text
11-data-quality-practice/
  README.md
  sql/
  dbt_tests/
  incidents/
  runbook/
  exercises/
  broken/
  solutions/
```

## Suggested Environment

You can run these checks against:

- `01-sql-practice/` PostgreSQL lab.
- Your own ecommerce Postgres database.
- BigQuery with minor syntax changes.
- dbt as generic/singular tests.

If using `01-sql-practice/`, run its setup first, then adapt table names:

```text
raw.orders
staging.stg_orders
marts.fct_orders
marts.dim_customers
```

## Quality Check Layers

```text
source/raw:
  freshness, file/partition presence, row count

staging:
  type validity, accepted values, null checks

facts/dimensions:
  uniqueness, referential integrity, grain checks

marts:
  reconciliation, business metrics, anomaly detection
```

## Actionable Check Standard

A useful check must answer:

- What failed?
- Which table/date/entity failed?
- What is expected?
- What is actual?
- Who owns it?
- What is the impact?
- What runbook should be used?

Bad alert:

```text
Data quality failed.
```

Good alert:

```text
P1: mart_daily_revenue freshness breach.
Owner: analytics-finance.
Impact: finance dashboard stale for 2026-05-09.
Expected: latest order_date >= 2026-05-09.
Actual: latest order_date = 2026-05-08.
Runbook: runbook/freshness_breach.md
```

## Recommended Learning Order

1. Read `sql/00_quality_metadata_schema.sql`.
2. Read and run checks in `sql/checks/`.
3. Review `broken/` scenarios.
4. Compare with `solutions/`.
5. Write one incident report from `incidents/templates/incident_template.md`.
6. Read runbooks.
7. Convert selected checks to dbt tests in `dbt_tests/`.

## Cost Considerations

Quality checks can be expensive if they scan full tables repeatedly.

Cost-aware patterns:

- Check recent partitions first.
- Use metadata tables for row counts and freshness.
- Aggregate source metrics once, then compare.
- Avoid full-table uniqueness checks every hour on huge facts.
- Run expensive reconciliation daily, not every 5 minutes.
- Partition quality tables by check date.
- Store check results for trend analysis.

## GitHub Deliverables

Your final output should include:

- Quality check SQL.
- Alert examples.
- Incident reports.
- Runbooks.
- Cost notes.
- A README explaining quality strategy by layer.

