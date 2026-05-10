# Solution 01 - Safe CI Workflow

Safe CI for pull requests should:

- use local/sample data
- avoid production credentials
- run deterministic tests
- fail fast on code/data test errors
- not write to production

Recommended jobs:

1. Python unit tests.
2. dbt parse/compile/build on sample DuckDB.
3. Secret scan.
4. Optional Docker build.

Production deploy should be a separate workflow with:

- protected branch
- environment approval
- restricted service account
- runbook
- rollback plan

