# Level 01 - CSV Ingestion

Goal: read CSV data, validate required columns, normalize records, and write raw copy.

Tasks:

1. Run the CSV pipeline.
2. Inspect logs.
3. Check raw copy under `data/raw/<run_id>/`.
4. Query PostgreSQL `orders`.
5. Explain why `O2002` loads once even though it appears twice in CSV.

Command:

```powershell
python -m src.main --source csv --input-path data/sample/orders.csv --run-date 2026-05-09
```

Expected learning:

- CSV headers must be validated.
- Bad data type is rejected.
- Missing customer ID is rejected.
- Duplicate business key is deduplicated by latest `updated_at`.

