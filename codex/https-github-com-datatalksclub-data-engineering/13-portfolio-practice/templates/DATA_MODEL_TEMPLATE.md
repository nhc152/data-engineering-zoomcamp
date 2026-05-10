# Data Model Template

## Purpose

Document model grain, keys, relationships, and metrics. This is one of the most important sections for Data Engineering interviews.

## Model Summary

| Model | Type | Grain | Primary Key | Purpose |
|---|---|---|---|---|
| `stg_orders` | staging | one row per deduplicated source order | `order_id` | clean raw orders |
| `fct_orders` | fact | one row per order | `order_id` | order-level metrics |
| `fct_order_items` | fact | one row per order item | `order_item_id` | product-level metrics |
| `dim_customers` | dimension | one row per customer | `customer_id` | customer attributes |
| `mart_daily_revenue` | mart | one row per date | `order_date` | dashboard revenue |

## Grain Explanation

Write this explicitly:

```text
`fct_orders` has one row per order. Order item rows are aggregated before joining so order-level revenue is not duplicated.
```

## Relationships

| From | To | Type | Risk |
|---|---|---|---|
| `fct_orders.customer_id` | `dim_customers.customer_id` | many-to-one | duplicate dim key can multiply facts |
| `fct_order_items.order_id` | `fct_orders.order_id` | many-to-one | joining then summing order revenue duplicates revenue |
| `fct_order_items.product_id` | `dim_products.product_id` | many-to-one | missing product creates orphan item |

## Metrics

| Metric | Definition | Source Model | Grain | Notes |
|---|---|---|---|---|
| `gross_item_amount` | quantity * unit_price | `fct_order_items` | item | product revenue source |
| `recognized_revenue` | captured payment for valid orders | `fct_orders` | order | excludes cancelled/refunded |
| `net_revenue` | captured - refunded | `fct_orders` | order | use for LTV |

## Data Quality Checks

| Check | Model | Expected |
|---|---|---|
| unique order_id | `fct_orders` | zero duplicates |
| not null order_id | `fct_orders` | zero nulls |
| relationships customer_id | orders -> customers | zero orphan rows |
| revenue reconciliation | payments -> orders | within tolerance |

## Known Modeling Trade-offs

Example:

```text
I keep both `fct_orders` and `fct_order_items`. `fct_orders` is safer for order/customer metrics. `fct_order_items` is required for product/category metrics. This avoids repeating order-level payment amount across item rows.
```

