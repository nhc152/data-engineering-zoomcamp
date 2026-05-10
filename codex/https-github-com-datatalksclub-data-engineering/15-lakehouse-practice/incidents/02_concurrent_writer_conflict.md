# Incident 02 - Concurrent Writer Conflict

## Symptom

Two pipelines wrote to the same silver table. One job succeeded, another failed with a commit conflict. Some downstream jobs read old data.

## Root Cause

Table ownership was unclear. Multiple writers attempted concurrent commits.

## Impact

- Delayed silver refresh.
- Downstream gold marts became stale.
- Manual rerun was required.

## Prevention

- One owning writer per table.
- Use orchestrated dependencies.
- Make writer jobs idempotent.
- Define conflict retry policy.
- Monitor failed commits.

