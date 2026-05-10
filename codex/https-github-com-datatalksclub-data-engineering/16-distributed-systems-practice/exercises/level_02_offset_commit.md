# Level 02 - Sink Write Before Offset Commit

## Goal

Understand at-least-once behavior when sink write succeeds but offset commit fails.

## Run

```bash
python scripts/02_consumer_crash_before_offset_commit.py
```

## Tasks

1. Explain the failure timeline.
2. Identify duplicate rows in naive sink.
3. Explain why idempotent sink is correct.
4. Write the equivalent Kafka failure scenario.

## Expected Learning

- Offset commit and sink write are separate side effects.
- Crash between them creates reprocessing.
- At-least-once is normal and must be designed for.

