# Broken Scenario - WAL/Binlog Retention Expires

## Symptom

CDC connector is down longer than source log retention. On restart, the connector cannot resume from the stored offset.

## Impact

- Changes during outage may be lost.
- Current-state table may be stale.
- Replaying from broker is impossible if events were never captured.

## Recovery

- Stop downstream publishing if correctness is affected.
- Run a new snapshot or targeted resnapshot.
- Compare counts/checksums.
- Rebuild current-state table.

## Prevention

- Monitor connector lag.
- Set source log retention above worst-case recovery time.
- Alert before retention window is exceeded.
- Keep raw changelog storage separate from source WAL/binlog.

