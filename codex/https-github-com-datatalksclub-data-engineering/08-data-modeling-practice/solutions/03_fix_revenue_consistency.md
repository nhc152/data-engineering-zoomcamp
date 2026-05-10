# Solution - Revenue Consistency

## Problem

Dashboard A uses `recognized_revenue`.

Dashboard B uses `gross_item_amount`.

Both are valid metrics, but they answer different questions.

## Fix

Define metrics explicitly:

- `gross_item_amount`: sum of item price times quantity.
- `recognized_revenue`: captured payment for non-cancelled and non-refunded orders.
- `net_revenue`: captured amount minus refunded amount.

## Modeling Rule

Dashboards should use curated marts:

- finance dashboard: `mart_daily_revenue.recognized_revenue` or `net_revenue`
- product dashboard: `mart_product_performance.product_gross_revenue`

## Prevention

- Maintain `docs/metric_definitions.md`.
- Add reconciliation checks.
- Avoid dashboard-level custom revenue SQL.
- Require metric review for KPI changes.

