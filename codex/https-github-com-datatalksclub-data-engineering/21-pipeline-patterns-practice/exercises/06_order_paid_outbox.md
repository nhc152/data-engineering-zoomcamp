# Exercise 06 - Order Paid Outbox

## Scenario

When an order is paid, multiple systems must react:

- send email
- update analytics
- trigger fulfillment
- update fraud monitoring

The event must only be published if the order transaction commits.

## Requirements

- Reliable event publication.
- Avoid dual-write inconsistency.
- Multiple consumers.
- Duplicate publish possible.
- Consumers must be idempotent.

## Tasks

1. Choose pattern.
2. Design outbox table.
3. Design event schema.
4. Design relay behavior.
5. Define duplicate handling.
6. Define consumer contracts.
7. Explain fan-out risk.

## Expected Direction

Likely pattern:

```text
Outbox pattern + fan-out
```

## Deliverable

Write:

```text
order_paid_outbox_design.md
```

