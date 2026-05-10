# Incident 01 - Vacuum Deleted Rollback Files

## Symptom

A gold finance table was corrupted by a bad transformation. The team tried to time travel to yesterday's snapshot, but required old files had already been deleted.

## Root Cause

Vacuum/cleanup retention was set too aggressively to reduce storage cost.

## Impact

- Rollback failed.
- Finance dashboard was unavailable.
- Team needed to rebuild table from upstream data.

## Detection Gap

There was no pre-vacuum checklist and no rollback SLA.

## Prevention

- Define retention by table criticality.
- Require approval before vacuuming gold finance tables.
- Monitor time-travel retention.
- Treat retention as reliability, not only cost control.

