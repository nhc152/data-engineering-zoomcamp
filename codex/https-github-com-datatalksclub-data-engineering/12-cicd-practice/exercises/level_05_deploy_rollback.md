# Level 05 - Deployment and Rollback

## Goal

Understand why rollback in data systems is harder than rollback in stateless apps.

## Tasks

1. Read `broken/02_dbt_deploy_breaks_dashboard.md`.
2. Read `broken/03_code_rollback_not_data_rollback.md`.
3. Read `solutions/03_data_rollback_strategy.md`.
4. Write a deployment checklist.
5. Write a rollback checklist.
6. Explain blue/green table or view swap strategy.

## Expected Learning

- Code rollback does not automatically repair corrupted data.
- Data changes may require reprocess/backfill.
- Deployment gates should compare row count and metrics before publish.

## Interview Question

A dbt model was deployed and wrote wrong revenue for 3 days. How do you recover?

