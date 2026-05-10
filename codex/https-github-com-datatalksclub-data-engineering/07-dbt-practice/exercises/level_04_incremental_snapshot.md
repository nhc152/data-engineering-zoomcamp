# Level 04 - Incremental Models and Snapshots

## Goal

Practice incremental model logic and snapshot history.

## Tasks

1. Run `dbt build --select fct_orders`.
2. Inspect `models/marts/core/fct_orders.sql`.
3. Explain the `is_incremental()` block.
4. Run `dbt snapshot`.
5. Inspect `snapshots.customers_snapshot`.

## Expected Learning

- Incremental models need unique key and safe watermark.
- Lookback window helps late-arriving updates.
- Snapshots track dimension changes over time.

## Questions

- Why is `updated_at` better than `created_at` for incremental filters?
- What late-arriving data can still be missed?
- When should you run full refresh?

