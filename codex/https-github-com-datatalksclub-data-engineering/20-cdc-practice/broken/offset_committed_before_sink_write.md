# Broken Scenario - Offset Committed Before Sink Write

## Symptom

Consumer resumes after an event, but the sink does not contain that event.

## Root Cause

Offset was committed before the sink transaction completed.

## Impact

This is data loss. Replay from consumer offset will skip the missing event.

## Reproduce Concept

```bash
python src/simulate_offset_failure.py
```

## Fix

- Write sink first.
- Commit sink transaction.
- Then commit offset.
- Make sink idempotent for replay after crash.

