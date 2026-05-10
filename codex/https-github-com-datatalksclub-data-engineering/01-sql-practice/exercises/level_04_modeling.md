# Level 04 - Modeling

Goal: build analytics-ready tables using staging, dimensions, facts, and marts.

## Tasks

1. Run all staging SQL files.
2. Run `marts/dim_customers.sql`.
3. Run `marts/dim_products.sql`.
4. Run `marts/fct_orders.sql`.
5. Run `marts/mart_daily_revenue.sql`.
6. Run `marts/mart_customer_ltv.sql`.
7. Write the grain for every mart object.
8. Explain why `fct_orders` aggregates order items and payments before joining.

## Grain Answers You Should Reach

- `marts.dim_customers`: one row per customer.
- `marts.dim_products`: one row per product.
- `marts.fct_orders`: one row per order.
- `marts.mart_daily_revenue`: one row per UTC order date.
- `marts.mart_customer_ltv`: one row per customer.

## Extension

Create a new mart:

```text
marts/mart_product_revenue.sql
```

Expected grain: one row per product.

Include:

- product_id
- product_name
- category
- total_quantity_sold
- gross_item_amount

## Done When

You can explain why raw, staging, fact, dimension, and mart layers exist separately.

