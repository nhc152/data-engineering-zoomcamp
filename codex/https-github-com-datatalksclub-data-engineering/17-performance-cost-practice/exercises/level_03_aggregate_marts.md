# Level 03 - Aggregate Marts

## Goal

Understand when pre-aggregating data reduces repeated serving cost.

## Tasks

1. Read `sql/07_aggregate_mart_bad.sql`.
2. Read `sql/09_create_aggregate_mart.sql`.
3. Read `sql/08_aggregate_mart_good.sql`.
4. Fill before/after metrics:
   - bytes scanned per dashboard refresh
   - refresh frequency
   - monthly estimated cost
5. Explain trade-off.

## Expected Learning

Aggregate marts trade storage and refresh jobs for cheaper, more predictable dashboard queries.

## Interview Question

When would you create a mart instead of letting BI query the fact table directly?

