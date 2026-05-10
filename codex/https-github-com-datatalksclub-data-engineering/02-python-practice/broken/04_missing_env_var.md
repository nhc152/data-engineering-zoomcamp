# Broken Scenario: Missing Env Var

Run:

```powershell
python -m src.main --source csv --input-path data/sample/orders.csv --run-date 2026-05-09 --env-file missing.env
```

Expected failure:

- The pipeline fails fast with `Missing required environment variable`.

Why this is good:

- A pipeline should not silently default to the wrong database.
- Failing before writing data is safer than writing to an unknown target.

