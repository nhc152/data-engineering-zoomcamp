# Level 02 - Table Format Comparison

## Goal

Compare Delta Lake, Apache Iceberg, and Apache Hudi for realistic requirements.

## Scenario

Your company has:

- Spark batch jobs.
- Trino for ad hoc SQL.
- CDC upserts from PostgreSQL.
- BI dashboards on gold tables.
- Need rollback after bad deploys.

## Tasks

1. Fill a decision matrix for Delta, Iceberg, Hudi.
2. Choose one format.
3. Explain trade-offs.
4. Identify operational risks.
5. Define catalog strategy.

## Expected Output

Create:

```text
notes/table_format_decision.md
```

Must include:

- current engines
- upsert/delete needs
- governance/catalog
- compaction/retention
- risks
- final recommendation

