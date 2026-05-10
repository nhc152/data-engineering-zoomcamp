# Model Answer - Order Paid Outbox

## Recommended Pattern

Outbox pattern with fan-out to consumers.

## Why

The payment transaction and event publication must be consistent. The outbox pattern avoids the dual-write problem by writing the business row and outbox row in the same database transaction.

## Architecture

```text
order payment transaction
  -> orders/payments table
  -> outbox table
  -> relay
  -> broker topic: order_paid
  -> email, fulfillment, analytics, fraud consumers
```

## Event Schema

Required fields:

- event_id.
- event_type.
- event_version.
- occurred_at.
- order_id.
- customer_id.
- payment_id.
- amount.
- currency.

## Failure Modes

- Relay publishes duplicate event.
- Relay lag delays consumers.
- Consumer is not idempotent.
- Schema change breaks downstream.

## Trade-off Language

Outbox improves reliability of event publication, but it does not remove the need for idempotent consumers and schema contracts.

