# Broken Scenario - Schema Rename Breaks Downstream

## Symptom

Source renames `order_status` to `status`. CDC events still arrive, but consumer cannot map fields correctly.

## Impact

- Current-state table misses status updates.
- Marts may show stale or null status.
- Tests may fail late, after bad data is applied.

## Diagnostic

```bash
python src/schema_evolution_check.py --events events/04_schema_drift.jsonl
```

## Prevention

- Schema compatibility checks.
- Versioned consumers.
- DLQ incompatible events.
- Source contract review for breaking changes.

