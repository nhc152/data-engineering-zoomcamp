# Level 01 - Format Comparison

## Goal

Compare CSV, JSONL, and Parquet for analytics.

## Tasks

1. Run `python src/generate_data.py --rows 50000`.
2. Run `python src/convert_formats.py`.
3. Open `data/reports/file_size_report.csv`.
4. Compare CSV, JSONL, uncompressed Parquet, Snappy, Gzip, and Zstd.
5. Write 5 bullets explaining what each format is good for.

## Expected Output

You should see a file size report like:

```text
artifact,size_mb
csv_raw,...
jsonl_raw,...
parquet_snappy,...
parquet_zstd,...
```

Exact values depend on row count and library versions.

## Questions

- Why is JSONL useful in raw layer?
- Why is Parquet better for analytics?
- Why is CSV risky for timestamps and null handling?
- Why does compression help columnar data?

