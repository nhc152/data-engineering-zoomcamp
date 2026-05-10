# Level 04 - Replay and Recovery

## Goal

Rebuild current-state table from raw changelog.

## Tasks

1. Apply snapshot and change stream.
2. Manually corrupt `cdc.orders_current`.
3. Run `sql/replay_from_changelog.sql`.
4. Validate current-state is restored.

## Example Corruption

```sql
update cdc.orders_current
set order_status = 'wrong'
where order_id = 'O1002';
```

## Expected Learning

- Raw changelog is the replay source.
- Current-state is derived and can be rebuilt.
- Replay must apply events in source order.

## Questions

- How much changelog retention is enough?
- What happens if WAL/binlog retention expires before capture?
- How do you replay only affected keys?
