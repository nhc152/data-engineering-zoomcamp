# Level 02 - Partitioning and Pruning

## Goal

Understand how partition layout affects query cost and performance.

## Tasks

1. Inspect `data/lake/orders_partitioned/`.
2. Run `python src/query_examples.py`.
3. Compare `partitioned_parquet_filter` with full month queries.
4. Read `queries/03_partition_pruning.sql`.
5. Write when `order_date` is a good partition key.

## Expected Learning

- Date partitioning is effective when most queries filter by date.
- Partitioning by high-cardinality keys creates too many folders/files.
- Partitioning does not replace good data modeling.

## Questions

- Why not partition by `customer_id`?
- What happens if partition is by `ingestion_date` but dashboards filter by `order_date`?
- When is reading a single partition useful?

