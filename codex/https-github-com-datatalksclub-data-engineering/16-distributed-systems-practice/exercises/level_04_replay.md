# Level 04 - Replay Safety

## Goal

Understand why replay can duplicate published data if outputs are not idempotent.

## Run

```bash
python scripts/04_replay_duplicates.py
```

## Tasks

1. Identify events already published before replay.
2. Compare naive publish table vs idempotent publish table.
3. Explain why replay is still necessary.
4. Design a safe backfill/replay process.

## Expected Learning

- Replay is a recovery feature.
- Replay without idempotent output is dangerous.
- Backfills should target partitions/keys safely.

