# Level 04 - Metric Definitions

## Goal

Prevent dashboard inconsistency by defining metrics centrally.

## Tasks

1. Read `docs/metric_definitions.md`.
2. Open `broken/03_inconsistent_revenue_definitions.sql`.
3. Identify why Dashboard A and Dashboard B disagree.
4. Choose the correct metric for finance reporting.
5. Choose the correct metric for product performance.
6. Read `solutions/03_fix_revenue_consistency.md`.

## Expected Output

You should produce a note:

```text
Finance revenue uses recognized_revenue or net_revenue from fct_orders.
Product performance uses gross_item_amount from fct_order_items.
These are different metrics and should not be compared as if they were the same.
```

## Questions

- Should cancelled orders contribute to recognized revenue?
- Should refunded orders reduce LTV?
- Who owns the revenue definition?

