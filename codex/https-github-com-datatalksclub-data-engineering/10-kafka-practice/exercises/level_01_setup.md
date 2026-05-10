# Level 01 - Setup

## Goal

Start Kafka, PostgreSQL, and Kafka UI locally.

## Tasks

1. Run `docker compose up -d`.
2. Confirm topics exist.
3. Open Kafka UI.
4. Connect to PostgreSQL.
5. Inspect tables.

## Commands

```bash
docker compose up -d
docker compose exec kafka kafka-topics.sh --bootstrap-server kafka:9092 --list
docker compose exec postgres psql -U kafka_user -d kafka_lab -c "\\dt"
```

## Expected Output

Topics:

```text
ecommerce.orders
ecommerce.orders.dlq
```

PostgreSQL tables:

```text
processed_events
orders_sink
dlq_events
```

