# Level 02 - JSON and JSONL

Goal: ingest JSON and JSONL while preserving raw data.

Tasks:

1. Run JSON ingestion.
2. Run JSONL ingestion.
3. Run bad JSONL file and observe failure.
4. Explain why JSONL is easier to debug line-by-line.

Commands:

```powershell
python -m src.main --source json --input-path data/sample/orders.json --run-date 2026-05-09
python -m src.main --source jsonl --input-path data/sample/orders.jsonl --run-date 2026-05-09
python -m src.main --source jsonl --input-path data/bad/orders_bad_jsonl.jsonl --run-date 2026-05-09
```

