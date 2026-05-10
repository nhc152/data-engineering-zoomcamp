# Level 03 - GitHub Actions

## Goal

Understand the CI workflow for a data project.

## Tasks

1. Open `.github/workflows/ci.yml`.
2. Identify the Python test job.
3. Identify the dbt build job.
4. Explain why dbt waits for Python tests.
5. Explain why this workflow does not use prod credentials.
6. Add a new step only if it is safe and deterministic.

## Expected Learning

CI should be:

- reproducible
- safe
- fast enough for PRs
- independent from production credentials

## Interview Question

What should a data pipeline CI workflow check before merge?

