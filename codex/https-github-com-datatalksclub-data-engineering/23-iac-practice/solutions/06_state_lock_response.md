# Solution 06 - State Lock Response

## Safe Response

1. Check whether another run is active.
2. Check CI logs.
3. Wait if a legitimate apply is running.
4. If lock is stale, use force unlock with change record.

## Why It Matters

State lock prevents concurrent writes. Force unlocking while another apply runs can corrupt state or create conflicting infrastructure changes.

## Prevention

- Single CI apply path for prod.
- Timeouts and cleanup on CI jobs.
- Clear ownership for lock handling.

