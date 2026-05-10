# Lakehouse Interview Cases

## Case 1: Parquet vs Lakehouse

Question:

> We already store Parquet files on GCS/S3. Why do we need Delta/Iceberg/Hudi?

Strong answer:

Parquet is a file format. Lakehouse table formats add table metadata, snapshots, transaction semantics, schema evolution, merge/upsert, delete handling, and time travel. If all you need is append-only archive, Parquet may be enough. If you need reliable table operations across engines, lakehouse formats become valuable.

## Case 2: Delta vs Iceberg vs Hudi

Question:

> Which table format would you choose?

Strong answer:

It depends on engines, governance, write patterns, and operational maturity. Delta is strong in Databricks/Spark workflows. Iceberg is strong for open multi-engine analytics and hidden partitioning. Hudi is strong for CDC/upsert-heavy ingestion and incremental pulls. I would decide based on current platform, catalog, upsert needs, streaming/batch requirements, and team operations capacity.

## Case 3: Vacuum Incident

Question:

> A team vacuumed old files and now cannot roll back. What went wrong?

Strong answer:

Retention was treated only as storage cleanup. In lakehouse, old files support time travel and rollback. The team needed retention policy by table criticality, pre-vacuum checks, owner approval, and rollback SLA.

## Case 4: Streaming Small Files

Question:

> Streaming writes are making lakehouse queries slow. What do you check?

Strong answer:

Check file count, average file size, partition layout, streaming trigger interval, compaction schedule, metadata operation time, and downstream query patterns. Fix by tuning micro-batch frequency, reducing over-partitioning, scheduling compaction, and monitoring table health.

## Case 5: When Not To Use Lakehouse

Question:

> When would you not use lakehouse?

Strong answer:

If data volume is moderate, team mostly needs SQL dashboards, and a managed warehouse solves the problem with less operational burden, I would use the warehouse. Lakehouse adds catalog, compaction, retention, concurrency, and schema policy operations. Use it when requirements justify that complexity.

