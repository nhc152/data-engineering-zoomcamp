# Metric Definitions

Metrics must be defined once and reused. A metric without a definition is a future incident.

## Revenue Metrics

### `gross_item_amount`

Grain:

- order item
- can be aggregated to order/date/product/customer

Definition:

```text
quantity * unit_price
```

Includes:

- all item lines, including cancelled/refunded orders unless filtered downstream

Does not include:

- tax
- shipping
- discounts unless represented in item price
- payment status

Primary source:

- `fct_order_items`

### `captured_amount`

Grain:

- payment transaction, aggregated to order

Definition:

```text
sum(payment.amount where payment_status = 'captured')
```

Primary source:

- `fct_payments`

### `recognized_revenue`

Grain:

- order

Definition:

```text
captured_amount for orders not cancelled and not refunded
```

Business rule:

- cancelled orders: 0
- refunded orders: 0 unless partial refund logic is explicitly modeled

Primary source:

- `fct_orders`

### `net_revenue`

Grain:

- order

Definition:

```text
captured_amount - refunded_amount
```

Use when:

- LTV
- finance reconciliation
- post-refund reporting

## Customer Metrics

### `lifetime_net_revenue`

Grain:

- customer

Definition:

```text
sum(net_revenue) across all customer orders
```

Important:

- refunds must be included
- cancelled orders should not contribute positive revenue

### `first_order_date`

Grain:

- customer

Definition:

```text
min(order_date)
```

Timezone:

- must match reporting timezone policy

## Product Metrics

### `product_gross_revenue`

Grain:

- product

Definition:

```text
sum(fct_order_items.gross_item_amount)
```

Important:

- do not calculate product revenue from order-level payment unless allocation is defined

### `units_sold`

Grain:

- product

Definition:

```text
sum(quantity)
```

## Event Metrics

### `daily_active_users`

Grain:

- reporting date

Definition:

```text
count(distinct customer_id) from fct_events
where event_name is an activity event
```

Timezone:

- must be defined explicitly
- example: `Asia/Ho_Chi_Minh` for Vietnam reporting

Risk:

- UTC date and local date can produce different DAU

## Metric Ownership

| Metric | Owner | Source Model | Notes |
|---|---|---|---|
| `recognized_revenue` | Finance analytics | `fct_orders` | excludes cancelled/refunded |
| `net_revenue` | Finance analytics | `fct_orders` | includes refunds |
| `product_gross_revenue` | Merchandising analytics | `fct_order_items` | item-level |
| `daily_active_users` | Product analytics | `fct_events` | timezone-sensitive |

## Semantic Consistency Rules

- Dashboard should not recalculate revenue from raw tables.
- BI should use marts or semantic layer.
- Metric definitions must mention grain and filters.
- Changes to metric definitions require review and backfill notes.

