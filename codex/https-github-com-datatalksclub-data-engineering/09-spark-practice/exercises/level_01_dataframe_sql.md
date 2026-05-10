# Level 01 - DataFrame API and Spark SQL

## Goal

Learn to express the same batch transformation in DataFrame API and Spark SQL.

## Tasks

1. Generate sample data.
2. Convert raw CSV/JSON to Parquet.
3. Run daily revenue with DataFrame API.
4. Run daily revenue with Spark SQL.
5. Compare outputs.
6. Use `explain(mode="formatted")` on one DataFrame.

## Commands

```bash
python src/00_generate_sample_data.py
python src/01_csv_json_to_parquet.py
python src/02_daily_revenue_dataframe.py
python src/03_daily_revenue_sql.py
```

## Expected Learning

- Spark builds a plan before executing.
- Actions such as `show`, `count`, and `write` trigger jobs.
- SQL and DataFrame API can produce the same output.

## Interview Question

When would you use DataFrame API vs Spark SQL?

