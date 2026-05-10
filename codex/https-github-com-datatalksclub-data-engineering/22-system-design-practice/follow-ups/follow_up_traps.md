# Interview Follow-up Traps

## If You Choose Kafka

Expect:

- How do you handle duplicates?
- What is the partition key?
- What happens with hot keys?
- What happens when a consumer crashes after sink write but before offset commit?
- How do you replay safely?
- How do you handle poison pills?

Weak answer:

```text
Kafka guarantees exactly once.
```

Stronger answer:

```text
Kafka can support strong guarantees in specific configurations, but end-to-end correctness still depends on producer config, consumer offset handling, idempotent sinks, and replay design.
```

## If You Choose CDC

Expect:

- How do you handle deletes?
- How do you handle schema changes?
- What if WAL/binlog retention expires?
- How do you resnapshot?
- How do you avoid older updates overwriting newer state?

## If You Choose Batch

Expect:

- How do you handle late-arriving data?
- How do you backfill?
- How do you avoid duplicate append?
- What quality checks run before publish?
- How do you reduce query cost?

## If You Choose Lakehouse

Expect:

- What table format?
- How do compaction and vacuum work?
- What is the time travel retention?
- What happens with concurrent writers?
- How do you manage metadata/catalog?

## If You Choose Metrics Layer

Expect:

- Who owns metric definitions?
- How are changes approved?
- How do you version metrics?
- How do you handle downstream impact?
- How do you reconcile finance metrics?

## General Trap Questions

- What would you simplify for version 1?
- What breaks first at 10x scale?
- What is the most expensive part?
- What is your replay path?
- What data quality check blocks publish?
- What happens if source sends duplicates?
- What happens if data arrives 3 days late?
- What happens if the dashboard is wrong for 2 days?

