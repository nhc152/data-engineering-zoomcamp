# Broken Scenario: Invalid Required Columns

Run:

```powershell
python -m src.main --source csv --input-path data/bad/orders_missing_columns.csv --run-date 2026-05-09
```

Expected failure:

- The CSV is missing `customer_id`.
- Validation fails before load.

Production lesson:

- Header validation catches source contract breaks early.

