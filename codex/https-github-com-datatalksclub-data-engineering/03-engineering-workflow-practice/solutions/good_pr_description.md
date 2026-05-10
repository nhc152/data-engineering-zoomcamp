# Good PR Description

## What changed

- Updated `fct_orders` recognized revenue logic.
- Cancelled and refunded orders now produce `recognized_revenue = 0`.
- Added validation notes for row count and revenue reconciliation.

## Why

Finance confirmed that cancelled/refunded orders should not count toward recognized revenue.

## Data impact

- Affected model: `fct_orders`.
- Affected metric: `recognized_revenue`.
- Grain changed: no.
- Backfill required: yes, for historical orders if this logic differs from current production.

## Validation

```text
fct_orders row count before: 10,000
fct_orders row count after:  10,000
duplicate order_id count:    0
cancelled/refunded revenue:  0
```

## Rollback plan

Revert this PR and rerun `fct_orders` for affected partitions.

