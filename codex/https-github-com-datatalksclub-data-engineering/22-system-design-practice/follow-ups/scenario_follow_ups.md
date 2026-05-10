# Scenario Follow-up Questions

## Ecommerce Warehouse

- How do you handle refunds that arrive after month close?
- How do you prevent duplicated revenue after joining order items?
- What table is partitioned and by what date?
- How do you backfill two years of revenue?
- How do you reconcile with finance?

## Clickstream Analytics

- How do you deduplicate events?
- How do you handle late events?
- How do you define a session?
- What happens if mobile app sends a new event version?
- How do you separate bots/internal traffic?

## Realtime Fraud

- What is the fallback if fraud service is down?
- How do you prevent duplicate decisions?
- What is the partition key?
- How do you monitor lag?
- How do you replay events for audit?

## CDC Ingestion Platform

- What happens when a source schema changes?
- How do you handle deletes?
- How do you resnapshot a table?
- What if connector lag exceeds source log retention?
- How do you validate current-state table?

## Metrics Platform

- Who approves metric changes?
- How do you version revenue?
- What happens when two teams disagree on active user?
- How do you prevent dashboard-specific metric logic?
- How do you track downstream impact?

