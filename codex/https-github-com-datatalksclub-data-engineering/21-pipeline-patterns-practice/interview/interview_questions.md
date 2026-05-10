# Interview Questions - Pipeline Patterns

## Core Questions

1. When would you choose Batch ELT instead of streaming?
2. What is the difference between CDC and semantic events?
3. Why is outbox pattern useful?
4. What is a DLQ and when does it become dangerous?
5. Lambda vs Kappa: what are the trade-offs?
6. What does replay mean in batch, CDC, and streaming?
7. Why is fan-in harder than a simple join?
8. What is the operational risk of fan-out?
9. When is micro-batch better than true streaming?
10. How do you choose a pipeline pattern in system design?

## Strong Answer Pattern

Use this structure:

```text
1. Clarify latency and correctness.
2. Identify source type and mutability.
3. Choose the simplest pattern that meets requirements.
4. Explain failure modes.
5. Explain replay/backfill.
6. Explain cost and operational complexity.
7. Explain why alternatives are weaker.
```

## Example Answer - Batch vs Streaming

Batch is better when the business can tolerate hourly or daily latency and needs strong replay, auditability, and lower operational complexity. Streaming is justified when decisions must happen within seconds or events need to trigger operational systems. I would not use streaming for a daily finance dashboard unless there is a clear freshness requirement.

## Example Answer - CDC vs Outbox

CDC captures database-level changes and is useful for replicating mutable tables into a warehouse. Outbox captures business-domain events reliably from application transactions. CDC is generic but can lack business semantics. Outbox is cleaner semantically but requires application engineering.

## Example Answer - DLQ

A DLQ stores records that cannot be processed so good data can continue. It must include raw payload, error reason, schema version, retry count, and owner. A DLQ without monitoring and replay process is just delayed data loss.

## Follow-up Traps

If you say Kafka:

- How do you handle duplicates?
- What is your replay strategy?
- What happens when a poison event appears?
- How do consumers handle schema changes?

If you say CDC:

- How do you handle deletes?
- What if source log retention expires?
- How do you handle out-of-order updates?
- How do you resnapshot safely?

If you say Batch ELT:

- How do you handle late-arriving data?
- How do you backfill?
- How do you prevent duplicate append?
- What quality checks run before publish?

