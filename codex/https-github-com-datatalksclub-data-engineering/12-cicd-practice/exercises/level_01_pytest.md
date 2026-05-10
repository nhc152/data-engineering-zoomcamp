# Level 01 - Python Unit Tests

## Goal

Use unit tests to protect small but important data transformation logic.

## Tasks

1. Inspect `src/transforms.py`.
2. Run `pytest -q`.
3. Add a new test for unknown status.
4. Break `normalize_status()` intentionally.
5. Confirm CI would catch the bug.
6. Restore the function.

## Expected Output

```text
5 passed
```

The exact number may increase if you add tests.

## Interview Question

Why are unit tests still useful in data engineering if most logic runs in SQL/dbt?

