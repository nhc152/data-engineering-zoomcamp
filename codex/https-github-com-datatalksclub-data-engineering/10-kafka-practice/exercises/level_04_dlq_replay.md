# Level 04 - DLQ and Replay

## Goal

Practice dead-letter handling and replay.

## Tasks

1. Produce `data/order_events.jsonl`.
2. Run consumer until poison pill is sent to DLQ.
3. Read DLQ.
4. Inspect `dlq_events` table.
5. Replay DLQ.
6. Run consumer again.
7. Validate `orders_sink`.

## Commands

```bash
python src/dlq_consumer.py
python src/replay_dlq.py
python src/consumer.py
```

## Expected Learning

- DLQ is not a fix by itself.
- DLQ needs owner, monitoring, and replay process.
- Replay should happen after understanding root cause.

