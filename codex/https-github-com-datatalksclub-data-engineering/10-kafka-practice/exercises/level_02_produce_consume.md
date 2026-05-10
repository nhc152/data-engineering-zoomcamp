# Level 02 - Produce and Consume

## Goal

Produce order events and consume them into PostgreSQL.

## Tasks

1. Install Python dependencies.
2. Produce `data/order_events.jsonl`.
3. Run safe consumer.
4. Inspect `orders_sink`.
5. Inspect `processed_events`.

## Commands

```bash
python src/producer.py --file data/order_events.jsonl
python src/consumer.py
```

In PostgreSQL:

```sql
select * from processed_events order by processed_at;
select * from orders_sink order by order_id;
```

## Expected Learning

- Producer key is `order_id`.
- Consumer writes to PostgreSQL before committing offset.
- Duplicate `event_id` is skipped.
- Poison pill event goes to DLQ.

