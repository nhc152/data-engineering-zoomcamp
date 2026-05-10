# Spark Practice Lab

## Goal

Practice production-style Spark batch processing with performance and debugging mindset.

Target flow:

```text
CSV/JSON raw files
  -> PySpark DataFrame/Spark SQL
  -> Parquet curated output
  -> partitioned marts
  -> quality checks
  -> performance debugging
```

This lab is local-first. It runs with PySpark in local mode, so you can learn Spark concepts without a cloud cluster.

## What You Will Learn

- PySpark DataFrame API.
- Spark SQL.
- CSV/JSON to Parquet.
- Partitioned output.
- Lazy evaluation.
- Job, stage, task mental model.
- Shuffle.
- Join strategies.
- Broadcast join.
- Skew debugging.
- Small files problem.
- Spark UI inspection.
- Common production failures.

## Prerequisites

Recommended:

- Python 3.11 or 3.12.
- Java 17.
- Enough disk space for generated sample data.

Install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

On Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Folder Structure

```text
09-spark-practice/
  README.md
  requirements.txt
  docker-compose.yml
  src/
  data/
    raw/
    output/
  exercises/
  broken/
  solutions/
  runbook/
```

## Quick Start

Generate sample data:

```bash
python src/00_generate_sample_data.py
```

Convert CSV/JSON to Parquet:

```bash
python src/01_csv_json_to_parquet.py
```

Build daily revenue with DataFrame API:

```bash
python src/02_daily_revenue_dataframe.py
```

Build daily revenue with Spark SQL:

```bash
python src/03_daily_revenue_sql.py
```

Compare join strategies:

```bash
python src/04_join_strategy.py
```

Run skew demo:

```bash
python src/05_skew_demo.py
```

Run small files compaction:

```bash
python src/06_small_files_compaction.py
```

Run quality checks:

```bash
python src/07_quality_checks.py
```

## Spark UI

When a Spark job is running, Spark UI is usually available at:

```text
http://localhost:4040
```

If one job finishes and another starts, the port can become `4041`, `4042`, etc.

Inspect:

- Jobs: how many actions triggered jobs.
- Stages: where shuffle boundaries happen.
- Tasks: whether one task is much slower than others.
- SQL/DataFrame tab: physical plan.
- Executors: memory, spill, task time.

For short local jobs, the UI may disappear after the script exits. To inspect UI longer, some scripts include a `--sleep-seconds` option.

Example:

```bash
python src/05_skew_demo.py --sleep-seconds 60
```

## Output Layout

Raw data:

```text
data/raw/orders/orders.csv
data/raw/order_items/order_items.csv
data/raw/products/products.csv
data/raw/payments/payments.jsonl
```

Curated output:

```text
data/output/parquet/orders/
data/output/parquet/order_items/
data/output/marts/daily_revenue/order_date=YYYY-MM-DD/
```

## Production Mindset

Spark performance is not magic. Most issues come from:

- Too much shuffle.
- Bad partitioning.
- Data skew.
- Driver misuse.
- Too many small files.
- Wrong join strategy.
- Bad overwrite behavior.
- Executor memory pressure.

Before optimizing, identify the symptom:

- Slow stage?
- One task much slower?
- Shuffle read/write huge?
- Driver memory high?
- Many tiny output files?
- Recomputed lineage from repeated actions?

## Failure Scenarios

Broken jobs are in `broken/`:

- `01_collect_crash_bad.py`
- `02_skewed_join_bad.py`
- `03_small_files_bad.py`
- `04_overwrite_bad.py`
- `05_executor_oom_bad.py`

Fixed versions are in `solutions/`.

## Recommended Learning Order

1. `exercises/level_01_dataframe_sql.md`
2. `exercises/level_02_parquet_partitioning.md`
3. `exercises/level_03_shuffle_join.md`
4. `exercises/level_04_skew_small_files.md`
5. `exercises/level_05_debugging_interview.md`

## GitHub Deliverables

After finishing the lab, your repo should show:

- PySpark jobs.
- Sample data generator.
- Partitioned Parquet output.
- Broken and fixed performance examples.
- README with Spark UI/debug notes.
- Runbook for slow Spark jobs.

