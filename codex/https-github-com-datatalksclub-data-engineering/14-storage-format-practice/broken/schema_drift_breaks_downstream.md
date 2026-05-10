# Broken Scenario - Schema Drift Breaks Downstream

## Symptom

Curated load or downstream query fails after a source adds a new field or changes a type.

## Example

`orders_schema_drift.jsonl` adds:

```text
coupon_code
```

It also writes `recognized_revenue` as a string in the drift sample.

## Root Cause

Raw JSON accepts shape changes, but curated tables need a stable schema.

## Diagnostic

```bash
python src/schema_drift_check.py
```

## Prevention

- Keep raw files.
- Validate schema before writing curated layer.
- Alert on new/missing/type-changed fields.
- Review schema changes via pull request.
- Version contracts for important sources.

