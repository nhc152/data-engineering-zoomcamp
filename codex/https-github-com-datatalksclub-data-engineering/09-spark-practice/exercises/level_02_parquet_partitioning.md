# Level 02 - Parquet and Partitioned Output

## Goal

Understand why Parquet and partitioned output matter for data lake batch processing.

## Tasks

1. Inspect raw CSV/JSON files.
2. Run `src/01_csv_json_to_parquet.py`.
3. Inspect output folder layout.
4. Find `order_date=YYYY-MM-DD` partitions.
5. Read only one partition in Spark.
6. Explain why partitioning by `order_date` helps downstream queries.

## Expected Output

You should see partitioned folders under:

```text
data/output/parquet/orders/order_date=2026-05-01/
```

## Interview Question

When can partitioning hurt instead of help?

