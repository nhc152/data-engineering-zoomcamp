# Level 06 - Exactly-Once Myth

## Goal

Understand why exactly-once guarantees are bounded.

## Run

```bash
python scripts/06_exactly_once_boundary.py
```

## Tasks

1. Identify the transaction boundary.
2. Explain why external sink writes are not automatically exactly-once.
3. List ways to make end state correct.
4. Explain this in interview language.

## Expected Learning

- Exactly-once is not magic end-to-end.
- External side effects require idempotency or transactions.
- Correct final state matters more than marketing labels.

