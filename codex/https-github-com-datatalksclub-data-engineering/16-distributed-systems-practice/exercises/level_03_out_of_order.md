# Level 03 - Out-of-Order CDC Events

## Goal

Understand why older updates can overwrite newer values if source ordering metadata is ignored.

## Run

```bash
python scripts/03_out_of_order_cdc.py
```

## Tasks

1. Compare naive state vs version-aware state.
2. Identify why version 2 arrives after version 3.
3. Explain why naive upsert is wrong.
4. Write a CDC prevention strategy.

## Expected Learning

- Current-state tables must compare source version/LSN/timestamp.
- Ordering is not global unless explicitly guaranteed.
- Keying by entity helps preserve per-entity order in Kafka.

