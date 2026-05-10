# Level 02 - Facts and Dimensions

## Goal

Design facts and dimensions for ecommerce analytics.

## Tasks

1. Read `docs/data_model.md`.
2. Inspect `sql/02_dimensions.sql`.
3. Inspect `sql/03_facts.sql`.
4. Explain why `fct_orders` aggregates items and payments before joining.
5. Explain why `fct_order_items` exists separately.
6. Explain when to use `dim_customers_current` vs `dim_customers_scd2`.

## Expected Output

You should be able to explain:

```text
fct_orders is order-level. It should not directly join raw item-level rows without aggregation.
fct_order_items is item-level. It is the correct source for product performance.
```

## Questions

- Which fact would you use for product category revenue?
- Which fact would you use for customer order count?
- Which dimension would you use for historical customer tier reporting?

