# <Project Name>

## Problem

Describe the business/data problem in 3-5 sentences.

Good:

```text
This project builds a daily ecommerce analytics pipeline that ingests order and payment data, preserves raw files, transforms them into warehouse marts, and validates revenue metrics before publishing dashboard-ready tables.
```

Avoid:

```text
This is a project where I learned Python, dbt, and Airflow.
```

## Architecture

```text
<source>
  -> <ingestion>
  -> <raw storage>
  -> <warehouse raw>
  -> <staging/intermediate/marts>
  -> <quality checks>
  -> <orchestration>
  -> <serving/dashboard>
```

Explain why each layer exists.

## Tech Stack

| Component | Tool | Why |
|---|---|---|
| Ingestion | Python | API/file ingestion with logging and retries |
| Storage | GCS/local lake | Preserve raw data for replay |
| Warehouse | BigQuery/PostgreSQL | SQL analytics and marts |
| Transformation | dbt/SQL | Modular transformations, tests, lineage |
| Orchestration | Kestra/Airflow | Scheduling, retries, backfill |
| Quality | dbt tests/SQL checks | Prevent bad data publish |
| CI | GitHub Actions | Run tests before merge |

## Data Source

Describe:

- source system
- data format
- refresh cadence
- expected volume
- known data quality issues

Example:

```text
Orders and payments are loaded daily from CSV/API sources. Raw files are stored by ingestion date. Known issues include duplicate order updates, inconsistent status casing, and late-arriving payment records.
```

## Data Model and Grain

| Model | Grain | Purpose |
|---|---|---|
| `stg_orders` | one row per deduplicated source order | clean and normalize raw orders |
| `fct_orders` | one row per order | order-level revenue and status |
| `fct_order_items` | one row per order item | product-level analytics |
| `dim_customers` | one row per customer | customer attributes |
| `mart_daily_revenue` | one row per reporting date | dashboard-ready revenue |

## Pipeline Flow

1. Extract source data.
2. Store raw files.
3. Load raw tables.
4. Build staging models.
5. Build facts/dimensions.
6. Build marts.
7. Run data quality checks.
8. Publish successful run.

## Setup

```bash
git clone <repo>
cd <repo>
cp .env.example .env
```

List dependencies:

- Docker
- Python
- dbt
- GCP credentials if applicable

## How to Run

Local:

```bash
docker compose up -d
```

Pipeline:

```bash
<exact command>
```

Tests:

```bash
<exact command>
```

## Data Quality Checks

| Check | Model | Why |
|---|---|---|
| unique order_id | `fct_orders` | preserve one row per order |
| not null keys | facts/dims | prevent broken joins |
| accepted status | `stg_orders` | catch source enum drift |
| revenue reconciliation | `fct_orders` | detect metric mismatch |
| freshness | raw/marts | detect stale data |

## Incremental and Backfill Strategy

Describe:

- full refresh or incremental
- unique key
- watermark
- lookback window
- late-arriving data handling
- backfill command

Example:

```text
The order fact is loaded incrementally using `updated_at` with a 2-day lookback and merge on `order_id`. Backfills are run by date range and are idempotent because the target partition is rebuilt or merged by key.
```

## Failure Handling

| Failure | Detection | Response |
|---|---|---|
| API timeout | task logs/retry count | retry with backoff |
| duplicate source rows | unique check | deduplicate in staging |
| late payment | reconciliation check | rerun affected window |
| schema drift | load/test failure | update staging through PR |
| expensive query | cost check/job history | add partition filter/mart |

## Cost and Scaling Considerations

Explain:

- partitioning strategy
- clustering/indexing if applicable
- query cost controls
- small file strategy
- expected bottleneck
- what changes at 10x data volume

## Trade-offs

| Decision | Option Chosen | Alternative | Trade-off |
|---|---|---|---|
| ELT vs ETL | ELT | ETL in Python | SQL lineage and warehouse scale, but warehouse cost must be watched |
| Batch vs streaming | Batch | Kafka streaming | simpler and cheaper, but higher latency |
| Full refresh vs incremental | Incremental | Full refresh | faster, but needs watermark and late-data handling |

## Known Limitations

Be honest:

- sample dataset is small
- no real production alerting
- no secrets manager
- no Terraform yet

## Future Improvements

List concrete improvements:

- add Terraform
- add CI/CD
- add source freshness monitoring
- add dashboard
- add CDC ingestion

## Interview Summary

In 5-7 sentences, summarize the project as you would in an interview.

