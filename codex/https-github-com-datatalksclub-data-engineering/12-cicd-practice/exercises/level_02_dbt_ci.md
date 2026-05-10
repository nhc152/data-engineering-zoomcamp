# Level 02 - dbt Build and Tests

## Goal

Run a local dbt project in CI style using deterministic sample data.

## Tasks

1. Go to `dbt_sample/`.
2. Run `dbt seed --profiles-dir .`.
3. Run `dbt build --profiles-dir .`.
4. Inspect `models/staging/schema.yml`.
5. Inspect `models/marts/schema.yml`.
6. Inspect singular tests in `tests/`.

## Expected Output

dbt should:

- load seed data
- build staging and mart models
- run generic tests
- run singular tests

## Interview Question

What is the difference between code tests and data tests?

