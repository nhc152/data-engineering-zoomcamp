# Solution - Idempotent Sink

The safe consumer uses two tables:

- `processed_events(event_id primary key)`
- `orders_sink(order_id primary key)`

Processing logic:

1. Insert `event_id` into `processed_events`.
2. If insert conflicts, skip the event as duplicate.
3. If insert succeeds, upsert into `orders_sink`.
4. Commit PostgreSQL transaction.
5. Commit Kafka offset.

This makes redelivery safe.

If the consumer crashes after DB commit but before offset commit:

- Kafka redelivers the same message.
- Consumer tries to insert same `event_id`.
- Conflict occurs.
- Event is skipped.
- Output is not duplicated.

