# Vacuum and Retention Policy

## Purpose

Vacuum/cleanup removes old files that are no longer referenced by active snapshots.

## Risk

If retention is too short, rollback and time travel can break.

## Policy

For production:

- Never set retention to zero for critical tables.
- Define retention by table criticality.
- Confirm no long-running readers depend on old snapshots.
- Confirm rollback SLA before cleanup.
- Document who can run vacuum/cleanup.

## Suggested Retention

| Table Type | Suggested Retention |
|---|---:|
| Bronze raw changelog | 30-180 days depending compliance |
| Silver current state | 7-30 days |
| Gold finance marts | 30-90 days |
| Temporary tables | 1-7 days |

## Pre-Vacuum Checklist

- Is there an active incident?
- Are backfills running?
- Are long-running queries using old snapshots?
- Is rollback window still satisfied?
- Has table owner approved?

## Incident Prevention

Retention is not only storage cleanup. It is a reliability feature.

