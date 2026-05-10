# Lakehouse Practice Lab

## Goal

Practice lakehouse architecture as a production design problem, not just as "Parquet files on object storage".

This lab is design-first. It does not require a real Databricks/Delta/Iceberg/Hudi runtime. The goal is to learn the concepts, decisions, policies, and failure modes that matter before choosing a lakehouse platform.

## Target Architecture

```text
OLTP / API / CDC / Events
        |
        v
Object storage landing zone
        |
        v
Bronze tables
  raw-ish, append-oriented, replayable
        |
        v
Silver tables
  cleaned, deduplicated, conformed
        |
        v
Gold tables
  facts, dimensions, marts, ML features
        |
        v
BI / ML / reverse ETL / serving systems
```

## What This Lab Teaches

- Medallion architecture.
- Delta/Iceberg/Hudi comparison.
- Why raw Parquet is not a lakehouse table.
- Table metadata and transaction logs.
- Snapshot isolation and ACID table concept.
- Time travel and rollback.
- Merge/upsert on object storage.
- Compaction and small files.
- Vacuum/retention.
- Schema evolution.
- Catalog and governance concerns.
- When not to use lakehouse.
- Production policies for table ownership and operations.

## Folder Structure

```text
15-lakehouse-practice/
  README.md
  docs/
  table-layout/
  policies/
  exercises/
  incidents/
  interview/
```

## Suggested Learning Order

1. Read `docs/01_lakehouse_architecture.md`.
2. Read `docs/02_delta_iceberg_hudi_comparison.md`.
3. Read `docs/03_table_metadata.md`.
4. Read `docs/04_when_not_to_use_lakehouse.md`.
5. Inspect `table-layout/`.
6. Study `policies/`.
7. Work through `exercises/`.
8. Review `incidents/`.
9. Practice `interview/`.

## Core Mental Model

A lakehouse table is not just files. It is:

```text
data files
  + metadata files
  + transaction log / snapshots
  + schema rules
  + catalog registration
  + operational policies
```

If you only have a folder of Parquet files, you have a data lake layout. You do not yet have full table semantics such as atomic commits, snapshot isolation, time travel, and safe merge/upsert.

## When Lakehouse Is a Good Fit

Lakehouse is useful when:

- You need open storage.
- You need multiple engines to read the same table.
- You need upsert/delete on lake data.
- You need CDC ingestion into object storage.
- You need time travel/rollback.
- You need batch and streaming to share table storage.
- You have large-scale data where warehouse-only cost or lock-in is a concern.

## When Not to Use Lakehouse

Do not use lakehouse just because it sounds modern.

Warehouse may be better when:

- Data volume is moderate.
- Team mostly uses SQL/BI.
- You need simple governance and managed performance.
- You do not have platform capacity to operate compaction/catalog/retention.
- The project is a small portfolio/demo.
- BigQuery/Snowflake can solve the problem with lower operational burden.

## GitHub Deliverables

For this lab, produce:

- Lakehouse architecture design doc.
- Delta/Iceberg/Hudi decision matrix.
- Medallion table layout.
- Table metadata explanation.
- Compaction policy.
- Vacuum/retention policy.
- Schema evolution policy.
- Incident writeups.
- Interview notes.

