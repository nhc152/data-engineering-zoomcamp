# Level 04 - Schema Evolution

## Goal

Detect schema drift before it silently breaks downstream jobs.

## Tasks

1. Run `python src/schema_drift_check.py`.
2. Compare `orders.jsonl` and `orders_schema_drift.jsonl`.
3. Identify added columns.
4. Identify type drift described by the script.
5. Write a response plan.

## Expected Output

The script should report:

```text
Added keys: ['coupon_code']
SCHEMA DRIFT DETECTED
```

## Questions

- Should raw layer accept new fields?
- Should curated layer automatically add new fields?
- How would a data contract help?
- What should happen if `recognized_revenue` changes from number to string?

