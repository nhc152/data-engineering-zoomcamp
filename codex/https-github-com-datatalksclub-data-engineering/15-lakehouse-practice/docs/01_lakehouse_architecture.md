# Lakehouse Architecture

## Problem Lakehouse Tries To Solve

Traditional data lakes are flexible but weak as tables:

- File overwrite is not atomic.
- Readers may see partial writes.
- Upsert/delete is hard.
- Schema evolution is inconsistent.
- Many engines may disagree about table state.
- Listing many files on object storage is slow.
- There is no reliable snapshot or rollback point.

Warehouses solve many of these problems but usually use managed storage and proprietary execution patterns.

Lakehouse tries to combine:

- Open object storage.
- Table metadata.
- ACID-like transactions.
- Time travel.
- Schema evolution.
- Multi-engine access.

## Reference Architecture

```text
Sources
  |-- OLTP CDC
  |-- API extracts
  |-- event streams
  |-- files
        |
        v
Landing zone
        |
        v
Bronze tables
        |
        v
Silver tables
        |
        v
Gold tables
        |
        v
Catalog + governance + quality + lineage
        |
        v
Consumers: BI, ML, product, reverse ETL
```

## Bronze Layer

Purpose:

- Preserve source-like data.
- Make replay possible.
- Avoid losing information.

Common data:

- CDC events.
- Raw JSON.
- API extracts.
- Event logs.

Rules:

- Do not hide source errors.
- Add ingestion metadata.
- Keep enough history for replay.
- Avoid heavy business logic.

Example columns:

```text
source_system
entity_name
operation
event_payload
source_updated_at
ingestion_timestamp
batch_id
```

## Silver Layer

Purpose:

- Clean and conform data.
- Deduplicate.
- Normalize schema.
- Apply technical quality rules.

Common transformations:

- Parse types.
- Normalize status.
- Deduplicate by key.
- Apply CDC latest-state logic.
- Enforce schema.

Rules:

- Output should be trusted by downstream teams.
- Keep grain explicit.
- Add quality checks.

## Gold Layer

Purpose:

- Business-ready facts, dimensions, marts.
- Stable definitions.
- BI and ML serving.

Common tables:

- `fct_orders`
- `fct_payments`
- `dim_customers`
- `mart_daily_revenue`
- `feature_customer_ltv`

Rules:

- Must have owner.
- Must have SLA.
- Must have quality checks.
- Must have clear retention and rollback policy.

## Catalog

Catalog maps table names to metadata and locations.

It answers:

- Where is the table?
- What schema is active?
- What snapshot is current?
- Who owns it?
- Which engine can read/write?

Catalog options depend on stack:

- Hive Metastore.
- AWS Glue Catalog.
- Unity Catalog.
- Nessie.
- Iceberg REST catalog.
- Platform-managed catalogs.

## Architecture Risks

- Too many engines writing to the same table.
- No clear table ownership.
- Compaction not scheduled.
- Vacuum retention too short.
- Schema evolution too permissive.
- Gold tables used as scratch tables.
- Catalog and object storage out of sync.

