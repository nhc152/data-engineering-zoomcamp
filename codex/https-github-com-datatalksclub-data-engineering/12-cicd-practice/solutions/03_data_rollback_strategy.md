# Solution 03 - Data Rollback Strategy

## Code Rollback

Use when:

- bad logic was deployed
- future runs must stop writing bad data

Code rollback does not fix data already written.

## Data Rollback Options

### Option 1: Restore Table Snapshot

Use when the warehouse supports snapshots/time travel.

Pros:

- fast recovery
- simple if snapshot exists

Cons:

- may lose valid writes after snapshot time
- retention window limited

### Option 2: Reprocess From Raw

Use when raw data is reliable and pipeline is deterministic.

Pros:

- correct rebuild
- auditable

Cons:

- can be expensive
- takes time

### Option 3: Blue/Green Swap

Build fixed version in green schema, validate, then switch view.

Pros:

- safer publish
- easy compare

Cons:

- more storage
- requires planning

## Minimum Runbook

1. Stop/pause affected pipeline.
2. Identify impacted date range.
3. Revert/fix code.
4. Rebuild affected data in staging.
5. Compare metrics.
6. Publish fixed data.
7. Document incident.

