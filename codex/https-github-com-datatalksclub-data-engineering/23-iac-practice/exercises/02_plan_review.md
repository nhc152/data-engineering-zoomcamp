# Exercise 02 - Plan Review

## Goal

Practice reviewing Terraform plans before apply.

## Tasks

1. Read `docs/plan_review_checklist.md`.
2. Read `broken/01_destroy_prod_bucket.md`.
3. Identify why the plan is dangerous.
4. Write the exact questions you would ask in PR review.
5. Compare with `solutions/01_prevent_destroy_bucket.md`.

## Expected Output

You should be able to say:

- I will not approve this plan because it destroys a production bucket.
- I need to know whether this is a rename, state issue, or intentional deletion.
- I would require backup/export, migration plan, and approval.

