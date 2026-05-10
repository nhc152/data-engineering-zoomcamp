# Broken Scenario - Delete Events Ignored

## Symptom

Deleted orders/users still appear as active in the warehouse.

## Root Cause

Consumer handles inserts/updates but ignores `op = d`.

## Impact

- Active counts are inflated.
- Compliance deletes may be violated.
- Downstream marts become wrong.

## Fix

- Apply delete events to current-state table.
- Use `is_deleted` and `deleted_at` if audit is needed.
- Ensure marts filter deleted rows intentionally.

