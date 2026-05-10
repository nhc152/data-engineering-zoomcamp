# Data Modeling Practice Lab

## Goal

Practice grain-first warehouse modeling for ecommerce analytics. This lab focuses on modeling decisions, metric consistency, and debugging wrong analytics caused by bad grain or incorrect joins.

Target architecture:

```text
raw source-like tables
  -> staging models
  -> intermediate grain alignment
  -> facts and dimensions
  -> business marts
  -> metric definitions and debugging scenarios
```

## What You Will Learn

- How to define grain before writing SQL.
- How to separate facts, dimensions, and marts.
- How star schema differs from snowflake schema.
- How SCD type 1 and SCD type 2 affect joins.
- How to model events and sessions.
- How duplicate metrics happen.
- How join explosion happens.
- Why semantic consistency matters.
- Why product revenue should not be calculated from order-level payment without allocation logic.
- How timezone changes DAU and daily revenue.
- How refunds affect LTV.

## Folder Structure

```text
08-data-modeling-practice/
  README.md
  docs/
    data_model.md
    metric_definitions.md
    erd.md
  sql/
  exercises/
  broken/
  solutions/
  interview/
```

## Recommended Learning Order

1. Read `docs/data_model.md`.
2. Read `docs/metric_definitions.md`.
3. Read `docs/erd.md`.
4. Inspect SQL files in `sql/`.
5. Work through `exercises/level_01_grain.md`.
6. Continue to modeling, SCD, events, and metric exercises.
7. Open `broken/` scenarios and write diagnostics before reading `solutions/`.
8. Use `interview/modeling_questions.md` to practice explaining trade-offs.

## Lab Dataset Concept

The ecommerce domain contains:

- customers
- products
- orders
- order items
- payments
- refunds
- customer tier history
- web events

Core grains:

| Model | Grain |
|---|---|
| `stg_orders` | one row per source order after deduplication |
| `stg_order_items` | one row per item line in an order |
| `stg_payments` | one row per payment transaction |
| `stg_refunds` | one row per refund transaction |
| `dim_customers_current` | one row per current customer |
| `dim_customers_scd2` | one row per customer version |
| `dim_products` | one row per product |
| `fct_orders` | one row per order |
| `fct_order_items` | one row per order item |
| `fct_payments` | one row per payment transaction |
| `fct_events` | one row per event |
| `mart_daily_revenue` | one row per reporting date |
| `mart_customer_ltv` | one row per customer |
| `mart_product_performance` | one row per product |

## Modeling Rules

1. Write grain before SQL.
2. Do not join one-to-many tables and sum parent-level metrics.
3. Aggregate child tables to the parent grain before joining if output grain is parent.
4. Use item-level fact for product/category metrics.
5. Join SCD2 dimensions with business key plus effective time range.
6. Define revenue once and reuse the definition.
7. Document timezone for every date metric.
8. Refunds and cancellations must be explicit in metric definitions.

## GitHub Deliverables

When complete, this lab should produce:

- `docs/data_model.md`
- `docs/metric_definitions.md`
- `docs/erd.md`
- SQL models with grain comments.
- Broken scenarios and diagnostic queries.
- Solutions that explain why the fix preserves grain.
- Interview notes.

