# Level 02 - External vs Managed Tables

## Goal

Understand when to use external tables and when to load data into BigQuery managed tables.

## Tasks

1. Run `bigquery/ddl/01_external_tables.sql`.
2. Query external tables.
3. Run `bigquery/ddl/02_managed_raw_tables.sql`.
4. Run `bigquery/queries/02_validate_external_vs_managed.sql`.
5. Explain trade-offs.

## Expected Output

External and managed row counts should match for the same source file.

Example:

```text
entity   external_rows   managed_rows
orders   6               6
payments 6               6
```

## Questions

- Why not query external tables directly for every dashboard?
- Why keep GCS raw files if data is loaded into BigQuery?
- What happens if raw file schema changes?

