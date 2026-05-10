# Solution - DLQ Replay Procedure

DLQ replay must be deliberate.

## Steps

1. Inspect DLQ event.
2. Identify whether failure is bad data, code bug, or downstream issue.
3. Fix source data or consumer code.
4. Replay small batch first.
5. Monitor consumer logs.
6. Validate sink table.
7. Commit replay run notes.

## Lab Command

```bash
python src/dlq_consumer.py
python src/replay_dlq.py
python src/consumer.py
```

## Production Warning

Do not auto-replay DLQ blindly. You can create repeated poison loops or corrupt downstream state.

