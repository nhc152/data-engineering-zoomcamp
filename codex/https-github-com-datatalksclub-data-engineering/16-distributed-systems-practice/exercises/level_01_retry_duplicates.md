# Level 01 - Retry and Duplicate Writes

## Goal

Understand why retry creates duplicate events and why idempotent sinks are mandatory.

## Run

```bash
python scripts/01_producer_retry_duplicate.py
```

## Tasks

1. Identify the duplicate `event_id`.
2. Compare naive sink vs idempotent sink.
3. Explain why producer retry happened.
4. Write a prevention strategy.

## Expected Learning

- A retry after lost acknowledgement can write the same logical event twice.
- Sink uniqueness by `event_id` prevents duplicate final state.
- Idempotent producer is not enough if downstream sink is not idempotent.

## Connect to Real Systems

- Kafka producer retry.
- Airflow task retry.
- Spark task retry writing output.
- API ingestion retry.

