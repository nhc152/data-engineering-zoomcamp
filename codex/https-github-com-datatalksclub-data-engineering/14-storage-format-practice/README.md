# Storage and File Format Practice Lab

## Goal

Practice production storage layout and file format decisions for Data Engineering.

Target flow:

```text
generated ecommerce rows
  -> CSV
  -> JSONL raw
  -> Parquet single file
  -> Parquet compressed variants
  -> Parquet partitioned dataset
  -> small files dataset
  -> compacted dataset
  -> DuckDB query comparisons
  -> schema drift and failure drills
```

This lab is local and runnable. It uses Python, PyArrow, Pandas, and DuckDB. It does not require cloud credentials.

## What You Will Learn

- CSV vs JSONL vs Parquet.
- Row-oriented vs columnar thinking.
- Compression trade-offs.
- Partition layout by date.
- Small files problem and compaction.
- Schema evolution and schema drift.
- Column pruning.
- Predicate pushdown.
- Why raw data should be retained for reprocessing.

## Prerequisites

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Folder Structure

```text
14-storage-format-practice/
  README.md
  requirements.txt
  src/
  data/
    raw/
    lake/
    reports/
  queries/
  exercises/
  broken/
  solutions/
  runbook/
```

Generated data is written under `data/`. You can delete it and regenerate anytime.

## Quick Start

Generate sample data:

```bash
python src/generate_data.py --rows 50000
```

Convert formats and build lake layouts:

```bash
python src/convert_formats.py
```

Run query comparisons:

```bash
python src/query_examples.py
```

Check schema drift:

```bash
python src/schema_drift_check.py
```

Run safe overwrite demo:

```bash
python src/wrong_partition_overwrite_demo.py
```

## Data Layout

Raw zone:

```text
data/raw/orders.csv
data/raw/orders.jsonl
data/raw/orders_schema_drift.jsonl
```

Lake zone:

```text
data/lake/orders_parquet/orders.parquet
data/lake/orders_parquet_snappy/orders.parquet
data/lake/orders_parquet_gzip/orders.parquet
data/lake/orders_parquet_zstd/orders.parquet
data/lake/orders_partitioned/order_date=YYYY-MM-DD/*.parquet
data/lake/orders_small_files/order_date=YYYY-MM-DD/part-*.parquet
data/lake/orders_compacted/order_date=YYYY-MM-DD/part-00000.parquet
```

## Expected Comparisons

The exact numbers depend on your machine and generated row count, but you should observe:

- CSV and JSONL are easier to inspect but larger and slower to scan.
- Parquet is smaller and faster for analytics.
- Selecting 3 columns from Parquet is faster than scanning all columns.
- Filtering partitioned Parquet by `order_date` reads less data.
- Many small files add planning/listing overhead.
- Compression reduces storage but can add CPU cost.

## Production Rules

- Keep raw data immutable.
- Convert raw JSON/CSV to typed Parquet for analytics.
- Partition by access pattern, usually event/order date.
- Avoid high-cardinality partition keys such as customer ID.
- Compact small files.
- Track schema changes before they break downstream jobs.
- Do not overwrite partitions without explicit date boundaries.

## Exercises

Start with:

1. `exercises/level_01_format_comparison.md`
2. `exercises/level_02_partitioning_pruning.md`
3. `exercises/level_03_small_files_compaction.md`
4. `exercises/level_04_schema_evolution.md`
5. `exercises/level_05_failure_scenarios.md`

## Broken Scenarios

- `broken/wrong_partition_overwrite.md`
- `broken/small_files_slow_planning.md`
- `broken/schema_drift_breaks_downstream.md`
- `broken/raw_json_deleted.md`
- `broken/compression_tradeoff.md`

## GitHub Deliverables

Your completed lab should include:

- generated reports in `data/reports/`
- notes comparing file sizes and query timings
- answers to exercises
- failure review notes
- screenshots or copied terminal output
- README notes explaining trade-offs

