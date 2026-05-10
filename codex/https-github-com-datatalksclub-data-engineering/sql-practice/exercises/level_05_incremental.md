# Level 05 - Incremental Loading

Goal: understand why incremental pipelines are harder than full refresh pipelines.

## Tasks

1. Inspect `incremental.pipeline_watermarks`.
2. Run `incremental/watermark_logic.sql`.
3. Run `incremental/append_load.sql` once.
4. Run `incremental/append_load.sql` a second time.
5. Detect duplicate rows in `incremental.fct_orders_append`.
6. Run `incremental/merge_upsert.sql`.
7. Explain why upsert is safer than append.
8. Run `incremental/late_arriving_data.sql`.
9. Explain why filtering only by `order_date` misses `O1010`.

## Concepts

- Append-only incremental loads are simple but dangerous.
- Merge/upsert protects business keys.
- Watermark should usually use `updated_at`, not only event date.
- Late-arriving data needs a lookback window.

## Questions to Answer

- What is the merge key?
- What is the watermark column?
- What late data can still be missed?
- How large should the lookback window be?
- What makes a job idempotent?

## Done When

You can explain the bug in `interview/incremental_failure.sql` and fix it.

