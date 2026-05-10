# Level 04 - Backfill Operations

## Goal

Design a safe backfill plan.

## Tasks

1. Read `backfill/backfill_plan_template.md`.
2. Read `backfill/backfill_90_day_orders_plan.md`.
3. Explain why blind append is unsafe.
4. Define validation checks.
5. Define rollback plan.
6. Define cost estimate process.

## Expected Output

Create:

```text
notes/backfill_plan_review.md
```

## Questions

- What tables are affected?
- What partitions will be rebuilt?
- What if validation fails?
- How will consumers be notified?
- How will you rollback?

