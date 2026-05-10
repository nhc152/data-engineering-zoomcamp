# Solution 06 - Exactly-Once Boundary

## Correct Statement

Exactly-once is scoped to a system boundary. Kafka transactional guarantees do not automatically make writes to an external warehouse exactly-once.

## Practical Data Engineering Rule

Design for:

```text
at-least-once processing + idempotent output = correct final state
```

## Prevention

- unique event IDs
- idempotent sink writes
- processed events table
- merge/upsert by business key
- transactional outbox/inbox when applicable
- replay tests

## Interview Answer

I do not rely on exactly-once as a blanket guarantee. I identify the boundary between log, processing, and sink, then make the sink idempotent so duplicate processing does not create duplicate state.

