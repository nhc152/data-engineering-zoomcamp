# Python Ingestion Runbook

## Pipeline Fails Before Extract

Check:

1. `.env` exists.
2. Required env vars are present.
3. PostgreSQL is running.
4. Database credentials are correct.

## Pipeline Fails During Extract

Check:

1. Source path exists.
2. JSON/JSONL is valid.
3. API pagination reaches all pages.
4. Retry attempts are bounded.
5. Rate limit behavior is logged.

## Pipeline Fails During Validation

Check:

1. Required columns.
2. Bad data type.
3. Missing business key.
4. Unknown status.
5. Rejected records count.

## Pipeline Loads Duplicate Data

Check:

1. Target table has unique constraint.
2. Upsert is used.
3. Business key matches intended grain.
4. Retry did not append blindly.
5. Dedup rule keeps latest `updated_at`.

## Pipeline Succeeds But Data Is Missing

Check:

1. Extracted count in logs.
2. Raw copy row count.
3. Rejected count.
4. Pagination logs.
5. `pipeline_runs` audit table.

