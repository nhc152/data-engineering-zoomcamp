# CDC Recovery Playbook

## Incident: Connector Lag Near WAL/Binlog Retention

### Triage

1. Check connector status.
2. Check source log retention window.
3. Check last captured LSN/binlog position.
4. Estimate time until retention expires.
5. Page owner if retention risk is high.

### Mitigation

- Scale/restart connector if safe.
- Reduce downstream bottleneck.
- Increase retention if possible.
- Prepare resnapshot plan.

## Incident: Current-State Table Corrupted

### Triage

1. Identify affected keys.
2. Check raw changelog completeness.
3. Check last good source position.
4. Stop downstream publish if needed.

### Recovery

1. Backup current table.
2. Replay raw changelog in source order.
3. Validate current-state output.
4. Rebuild marts.
5. Resume publish.

## Incident: Delete Events Ignored

### Triage

1. Count delete events in changelog.
2. Check `is_deleted` in current-state.
3. Identify active marts that should exclude deleted rows.

### Recovery

1. Fix delete handling.
2. Replay changelog or affected keys.
3. Rebuild downstream marts.

## Incident: Schema Drift

### Triage

1. Compare event schema with contract.
2. Identify added, missing, renamed, type-changed fields.
3. Send incompatible events to DLQ if necessary.

### Recovery

1. Update consumer mapping.
2. Replay DLQ/changelog.
3. Backfill current-state and marts.

