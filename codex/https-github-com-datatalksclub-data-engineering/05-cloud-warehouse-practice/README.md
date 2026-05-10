# Cloud Warehouse Practice Lab

## Goal

Practice a production-style GCP data lake and BigQuery warehouse flow:

```text
local sample data
  -> GCS raw zone
  -> BigQuery external tables
  -> BigQuery managed raw tables
  -> staging views
  -> partitioned/clustered marts
  -> cost checks and failure debugging
```

This lab is designed for learning. It does not include real credentials. You must configure your own GCP project, billing, service account, and budget alerts.

## What You Will Learn

- GCP project setup mindset.
- GCS bucket and prefix layout.
- Service account and least-privilege IAM.
- Raw zone naming by `ingestion_date`.
- BigQuery external vs managed tables.
- Warehouse layers: raw, staging, marts.
- Partitioning and clustering.
- Query bytes scanned and dry runs.
- Cost optimization patterns.
- Schema drift handling.
- Real failure scenarios: location mismatch, full table scan, over-permissioned service account, raw overwrite, load failure.

## Prerequisites

Install locally:

- Google Cloud SDK.
- `bq` CLI, included with Google Cloud SDK.
- A GCP project with billing enabled.
- A budget alert configured in GCP Billing.

Recommended:

- Use a dedicated learning project.
- Set a low budget alert, for example 5-10 USD.
- Do not use production credentials.

## Environment

Copy `.env.example` to `.env` and fill values for your own project.

```bash
cp .env.example .env
```

Do not commit `.env`.

Example variables:

```bash
GCP_PROJECT_ID=your-learning-project
GCP_LOCATION=US
GCS_BUCKET=your-unique-de-learning-bucket
BQ_RAW_DATASET=de_raw
BQ_STAGING_DATASET=de_staging
BQ_MARTS_DATASET=de_marts
SERVICE_ACCOUNT_NAME=de-lab-loader
```

## Architecture

```text
05-cloud-warehouse-practice/data/
        |
        v
gs://<bucket>/raw/ecommerce/<entity>/ingestion_date=YYYY-MM-DD/
        |
        v
BigQuery external tables
        |
        v
BigQuery raw managed tables
        |
        v
staging views
        |
        v
partitioned and clustered marts
        |
        v
cost checks and debugging queries
```

## Folder Structure

```text
05-cloud-warehouse-practice/
  README.md
  .env.example
  data/
  gcs-layout/
  bigquery/
    ddl/
    queries/
    cost_checks/
  exercises/
  broken/
  solutions/
  runbook/
```

## Setup Commands

Authenticate:

```bash
gcloud auth login
gcloud auth application-default login
```

Set project:

```bash
gcloud config set project "$GCP_PROJECT_ID"
```

Enable APIs:

```bash
gcloud services enable storage.googleapis.com bigquery.googleapis.com iam.googleapis.com
```

Create bucket:

```bash
gcloud storage buckets create "gs://$GCS_BUCKET" --location="$GCP_LOCATION" --uniform-bucket-level-access
```

Create datasets:

```bash
bq --location="$GCP_LOCATION" mk --dataset "$GCP_PROJECT_ID:$BQ_RAW_DATASET"
bq --location="$GCP_LOCATION" mk --dataset "$GCP_PROJECT_ID:$BQ_STAGING_DATASET"
bq --location="$GCP_LOCATION" mk --dataset "$GCP_PROJECT_ID:$BQ_MARTS_DATASET"
```

Upload sample data:

```bash
gcloud storage cp data/customers.csv "gs://$GCS_BUCKET/raw/ecommerce/customers/ingestion_date=2026-05-01/customers.csv"
gcloud storage cp data/orders.csv "gs://$GCS_BUCKET/raw/ecommerce/orders/ingestion_date=2026-05-01/orders.csv"
gcloud storage cp data/order_items.csv "gs://$GCS_BUCKET/raw/ecommerce/order_items/ingestion_date=2026-05-01/order_items.csv"
gcloud storage cp data/payments.csv "gs://$GCS_BUCKET/raw/ecommerce/payments/ingestion_date=2026-05-01/payments.csv"
gcloud storage cp data/orders_schema_drift.csv "gs://$GCS_BUCKET/raw/ecommerce/orders/ingestion_date=2026-05-02/orders_schema_drift.csv"
```

Run BigQuery SQL files by replacing placeholders:

- `PROJECT_ID`
- `RAW_DATASET`
- `STAGING_DATASET`
- `MARTS_DATASET`
- `GCS_BUCKET`

You can run through BigQuery console, `bq query`, or your SQL editor.

## Recommended Execution Order

1. Read `gcs-layout/README.md`.
2. Read `gcs-layout/iam_matrix.md`.
3. Run `bigquery/ddl/00_create_datasets.sql` if you prefer SQL DDL.
4. Run `bigquery/ddl/01_external_tables.sql`.
5. Run `bigquery/ddl/02_managed_raw_tables.sql`.
6. Run `bigquery/ddl/03_staging_views.sql`.
7. Run `bigquery/ddl/04_marts_partitioned_clustered.sql`.
8. Run queries in `bigquery/queries/`.
9. Run cost checks in `bigquery/cost_checks/`.
10. Work through `exercises/`.
11. Debug `broken/`.
12. Compare with `solutions/`.

## Warehouse Layers

### GCS Raw Zone

Raw files are stored with ingestion date:

```text
gs://<bucket>/raw/ecommerce/orders/ingestion_date=2026-05-01/orders.csv
```

Raw data should be append-only. Backfills should write a new partition/path instead of overwriting previous raw files.

### BigQuery External Tables

External tables let BigQuery read files directly from GCS. They are useful for inspecting raw files and validating load patterns.

Trade-off:

- Lower setup cost.
- Data remains in GCS.
- Performance and governance can be weaker than managed tables.

### BigQuery Managed Raw Tables

Managed tables copy data into BigQuery storage. They are better for production warehouse layers.

Trade-off:

- Better query behavior and table management.
- Duplicates storage relative to GCS.
- Requires load/insert process.

### Staging Views

Staging views normalize names, cast types, clean status casing, and expose consistent column names.

### Marts

Marts are partitioned and clustered for business queries.

In this lab:

- `fct_orders` is partitioned by `order_date`.
- `fct_orders` is clustered by `customer_id`, `order_status`.
- `mart_daily_revenue` is a daily aggregate.

## Cost Mindset

Before running large queries:

```bash
bq query --use_legacy_sql=false --dry_run '<SQL>'
```

In BigQuery UI, check:

- Bytes processed.
- Whether partition filter is applied.
- Whether query scans unnecessary columns.
- Whether dashboard query should use aggregate mart instead of fact/raw.

Cost rules:

- Avoid `select *` on large tables.
- Filter partitioned facts by date.
- Query marts for dashboards.
- Use dry runs.
- Label jobs/resources when possible.

## Debugging Workflow

When data is missing:

1. Check whether file exists in GCS.
2. Check bucket and dataset location.
3. Check external table URI.
4. Check schema and header options.
5. Check load job errors.
6. Check staging filters/casts.
7. Check mart partition date.

When query is expensive:

1. Check bytes processed.
2. Check selected columns.
3. Check partition filter.
4. Check whether query hits raw, fact, or mart.
5. Check join cardinality.
6. Consider aggregate mart.

## GitHub Deliverables

Your completed lab should include:

- GCS layout documentation.
- IAM matrix.
- BigQuery DDL.
- Cost comparison queries.
- Broken scenarios and solutions.
- Runbook.
- Screenshots or copied dry-run output.
- README notes explaining trade-offs.

