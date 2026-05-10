# Level 03 - Simulated API Ingestion

Goal: practice pagination, timeout retry, rate limit retry, and raw page extraction.

Tasks:

1. Run API ingestion.
2. Observe logs for retryable timeout and rate-limit simulation.
3. Confirm all pages are fetched.
4. Explain what would happen if the pipeline stopped after page 1.

Command:

```powershell
python -m src.main --source api --api-pages-dir data/sample/api_pages --run-date 2026-05-09
```

Expected learning:

- Pagination needs a termination condition.
- Retry must be bounded.
- Retry must not create duplicate sink rows.
- Raw copy enables reprocessing.

