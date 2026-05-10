# Catalog and Governance Policy

## Purpose

Catalog makes lakehouse tables discoverable, governable, and queryable by multiple engines.

## Required Table Metadata

Each production table should have:

- owner
- domain
- layer: bronze/silver/gold
- purpose
- grain
- primary/business key
- SLA
- retention policy
- schema evolution policy
- PII classification
- allowed writers
- allowed readers

## Writer Policy

Only one owning pipeline should write to a table unless a platform pattern explicitly supports multiple writers.

Avoid:

- ad hoc notebooks writing gold tables
- multiple teams merging into same table
- manual object storage edits

## Reader Policy

Readers should access tables through catalog names, not raw object paths.

Bad:

```text
read parquet from gs://bucket/gold/finance/fct_orders/*
```

Better:

```text
select * from catalog.gold.finance.fct_orders
```

## Catalog Failure Risks

- Catalog points to stale metadata.
- Table dropped from catalog but files remain.
- Files deleted but catalog still references them.
- Different engines use incompatible table format versions.

