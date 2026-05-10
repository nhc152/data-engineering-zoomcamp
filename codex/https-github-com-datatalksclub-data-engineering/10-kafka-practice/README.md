# Kafka Practice Lab

## Goal

Practice Kafka streaming fundamentals with production correctness:

```text
producer -> Kafka topic -> consumer group -> idempotent PostgreSQL sink
                              |
                              v
                            DLQ
```

This lab is intentionally focused on correctness, not high throughput. You will practice at-least-once processing, offset commit timing, idempotent writes, DLQ handling, replay, lag, and hot partitions.

## What You Will Learn

- Kafka Docker Compose setup.
- Topics and partitions.
- Producer keys and ordering.
- Consumer groups.
- Manual offset commit.
- At-least-once behavior.
- Idempotent PostgreSQL sink using `event_id`.
- Poison pill handling.
- DLQ production and replay.
- Lag debugging.
- Hot partition diagnosis.
- Why "exactly once" is not magic end-to-end.

## Folder Structure

```text
10-kafka-practice/
  docker-compose.yml
  README.md
  .env.example
  requirements.txt
  src/
    config.py
    producer.py
    consumer.py
    dlq_consumer.py
    replay_dlq.py
  sql/
    00_schema.sql
  data/
    order_events.jsonl
    hot_partition_events.jsonl
  exercises/
  broken/
  solutions/
  runbook/
```

## Start Services

```bash
docker compose up -d
```

Services:

- Kafka broker: `localhost:9094`
- PostgreSQL: `localhost:5432`
- Kafka UI: `http://localhost:8080`

PostgreSQL credentials:

```text
database: kafka_lab
user: kafka_user
password: kafka_password
```

## Python Setup

Use a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

On PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Copy env file:

```bash
cp .env.example .env
```

## Run Producer

Produce normal events:

```bash
python src/producer.py --file data/order_events.jsonl
```

Produce hot partition events:

```bash
python src/producer.py --file data/hot_partition_events.jsonl
```

## Run Consumer

```bash
python src/consumer.py
```

The consumer uses this safe pattern:

```text
poll event
validate event
write output idempotently to PostgreSQL
commit Kafka offset after DB commit
```

If an event cannot be processed after retries, it is sent to `ecommerce.orders.dlq` and the original offset is committed so the consumer group can continue.

## Inspect PostgreSQL

```bash
docker compose exec postgres psql -U kafka_user -d kafka_lab
```

Useful queries:

```sql
select * from processed_events order by processed_at;
select * from orders_sink order by order_id;
select * from dlq_events order by failed_at;
```

## Inspect Kafka Topics

```bash
docker compose exec kafka kafka-topics.sh --bootstrap-server kafka:9092 --list
docker compose exec kafka kafka-consumer-groups.sh --bootstrap-server kafka:9092 --describe --group orders-postgres-sink
```

Or open Kafka UI:

```text
http://localhost:8080
```

## DLQ

Read DLQ:

```bash
python src/dlq_consumer.py
```

Replay DLQ:

```bash
python src/replay_dlq.py
```

In production, replay should not be automatic. You should inspect the error, fix data or code, then replay deliberately.

## Failure Modes Included

### Poison Pill Event

`data/order_events.jsonl` includes an invalid event with missing/invalid amount. The consumer sends it to DLQ.

### Duplicate Event

The sample data includes a duplicate `event_id`. The sink prevents double-processing through `processed_events(event_id primary key)`.

### Commit Before Sink Write

`broken/commit_before_sink_write.py` shows a dangerous consumer pattern that commits offset before writing to PostgreSQL. If it crashes after commit, data is lost for that consumer group.

### Sink Write Before Offset Commit

The safe consumer writes to DB before committing offset. If it crashes after DB write but before offset commit, Kafka may redeliver the event. The PostgreSQL idempotency table prevents duplicate output.

### Hot Partition

`data/hot_partition_events.jsonl` uses the same key for many events. This creates partition imbalance and lag in real systems.

### DLQ Not Replayed

DLQ is only useful if someone owns it, monitors it, and has a replay process.

## Recommended Learning Order

1. Read `exercises/level_01_setup.md`.
2. Start Docker Compose.
3. Produce events.
4. Run safe consumer.
5. Inspect PostgreSQL output.
6. Read and run broken scenarios.
7. Inspect DLQ.
8. Replay DLQ after understanding why it failed.
9. Produce hot partition data.
10. Check consumer group lag.

## GitHub Deliverables

Your final notes should include:

- Architecture diagram.
- Topic configuration.
- Consumer group behavior.
- Offset commit explanation.
- Idempotency strategy.
- DLQ strategy.
- Replay strategy.
- Lag debugging notes.
- Failure scenario explanations.

