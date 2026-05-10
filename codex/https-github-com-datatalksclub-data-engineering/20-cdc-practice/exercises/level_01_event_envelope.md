# Level 01 - Debezium-Style Event Envelope

## Goal

Understand CDC event shape.

## Tasks

1. Open `events/01_snapshot_orders.jsonl`.
2. Identify `before`, `after`, `source`, `op`, `ts_ms`.
3. Identify primary key.
4. Identify source log position.
5. Explain why `op` is required.

## Expected Learning

- Snapshot events use `op = r`.
- Insert events use `op = c`.
- Update events use `op = u`.
- Delete events use `op = d`.
- Tombstone events may have `payload = null`.

## Questions

- Why does downstream need `before` and `after`?
- Why is source LSN/binlog position important?
- Why is event timestamp not enough for ordering?

