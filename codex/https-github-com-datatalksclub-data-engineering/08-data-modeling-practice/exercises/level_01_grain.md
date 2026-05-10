# Level 01 - Grain First

## Goal

Learn to define grain before writing joins.

## Tasks

1. Write the grain for:
   - customers
   - products
   - orders
   - order_items
   - payments
   - refunds
   - events
2. Identify primary/business key for each.
3. Identify which tables are one-to-many with orders.
4. Predict which joins can create row explosion.

## Expected Output

Example:

```text
fct_orders: one row per order. Key: order_id.
fct_order_items: one row per order item. Key: order_item_id.
```

## Questions

- Why is `orders -> order_items` one-to-many?
- Why is `orders -> payments` potentially one-to-many?
- Why can SCD2 dimensions duplicate rows?

