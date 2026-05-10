# When Not To Use Lakehouse

Lakehouse is powerful, but not free. It adds operational complexity.

## Do Not Use Lakehouse When

### Data volume is small

If your data is a few GB and BigQuery/Snowflake/Postgres solves it, lakehouse may be overkill.

### Team mostly needs BI SQL

Managed warehouse gives simpler:

- permission
- performance
- SQL UX
- dashboard integration
- governance

### You cannot operate metadata and compaction

Lakehouse needs:

- compaction jobs
- snapshot cleanup
- catalog management
- schema evolution policy
- writer coordination

If nobody owns these, table health will degrade.

### You have no upsert/delete/time travel requirement

If all pipelines are append-only and warehouse cost is acceptable, a warehouse-first architecture may be simpler.

### Portfolio project is too early

For early Data Engineering learning:

1. SQL
2. Python
3. Docker
4. Warehouse
5. dbt
6. Orchestration

These usually matter before lakehouse.

## Better Alternatives

| Situation | Simpler Option |
|---|---|
| BI reporting | BigQuery/Snowflake warehouse |
| Small batch project | Postgres/BigQuery |
| Raw archive | GCS/S3 raw files |
| SQL transformations | dbt on warehouse |
| One-engine Spark pipeline | Parquet + clear layout may be enough initially |

## Senior Rule

Choose lakehouse because requirements demand it, not because the architecture diagram looks modern.

