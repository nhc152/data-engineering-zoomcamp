# Solution - Schema Drift Response

## Short-Term Lab Fix

Do not load `orders_schema_drift.csv` into the original strict table without reviewing the new column.

Options:

1. Create a new external table for May 2 file with autodetect.
2. Compare schema.
3. Decide whether to add `coupon_code` to raw and staging.

## Production Fix

1. Add schema validation before load.
2. Alert on new/missing/changed columns.
3. Keep raw file even if load fails.
4. Update staging model through pull request.
5. Backfill downstream marts if the new column affects metrics.

## Rule

Schema drift should be visible and reviewed, not silently absorbed into production marts.

