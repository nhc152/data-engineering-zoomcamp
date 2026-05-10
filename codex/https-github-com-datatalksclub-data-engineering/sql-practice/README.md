# SQL Practice Lab for Data Engineering

This lab is a local PostgreSQL environment for practicing production-style Data Engineering SQL.

It is not LeetCode SQL. The goal is to practice the SQL work Data Engineers do in real pipelines:

- clean raw data
- debug duplicate records
- detect join explosion
- build staging, dimension, fact, and mart layers
- reconcile source and target data
- design incremental loads
- handle late-arriving data
- explain decisions in interviews

## Architecture

```text
raw ecommerce tables
        |
        v
staging views
        |
        v
dimension and fact tables/views
        |
        v
mart tables/views
        |
        v
quality checks and interview debugging scenarios
```

## Folder Structure

```text
sql-practice/
├── docker-compose.yml
├── README.md
├── init/
├── staging/
├── marts/
├── quality/
├── incremental/
├── exercises/
├── interview/
└── solutions/
```

## Setup

Start PostgreSQL:

```bash
docker compose up -d
```

Connect with psql:

```bash
docker compose exec postgres psql -U de_user -d de_sql_practice
```

Stop the database:

```bash
docker compose down
```

Reset all data:

```bash
docker compose down -v
docker compose up -d
```

## Running SQL Files

Run a file from inside the container:

```bash
docker compose exec postgres psql -U de_user -d de_sql_practice -f /workspace/file.sql
```

The repo is not mounted into the container by default. The simplest local workflow is:

```bash
docker compose exec -T postgres psql -U de_user -d de_sql_practice < staging/stg_orders.sql
```

On PowerShell:

```powershell
Get-Content .\staging\stg_orders.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
```

## Schema Explanation

The init scripts create these schemas:

- `raw`: source-like tables with dirty data.
- `staging`: cleaned views.
- `marts`: dimensions, facts, and analytics marts.
- `quality`: optional place for saved quality objects.
- `incremental`: incremental load demo tables.

Main raw tables:

- `raw.customers`: one row should represent one customer, but bad data includes duplicates and updates.
- `raw.products`: one row should represent one product.
- `raw.orders`: one row should represent one order, but bad data includes duplicate order versions.
- `raw.order_items`: one row represents one product line in an order.
- `raw.payments`: one row represents one payment transaction.
- `raw.events`: one row represents one application event, but bad data includes duplicate events.

## Grain Explanation

Always write the grain before writing a join:

- `raw.orders`: one row per order version in source, not guaranteed unique by `order_id`.
- `staging.stg_orders`: one row per final deduplicated order.
- `raw.order_items`: one row per order item.
- `marts.fct_orders`: one row per order.
- `marts.mart_daily_revenue`: one row per order date.
- `marts.mart_customer_ltv`: one row per customer.

The most common bug in this lab is joining `orders` to `order_items` and then summing order-level payment values. That changes the grain from order to order-item and duplicates revenue.

## Suggested Learning Order

1. Start Docker and inspect raw tables.
2. Read `exercises/level_01_foundation.md`.
3. Run staging scripts.
4. Run mart scripts.
5. Run quality checks.
6. Try the interview broken SQL files before opening solutions.
7. Study incremental scripts last.

## Recommended Run Order

```powershell
Get-Content .\staging\stg_customers.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\staging\stg_orders.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\staging\stg_order_items.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\staging\stg_payments.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\marts\dim_customers.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\marts\dim_products.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\marts\fct_orders.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\marts\mart_daily_revenue.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
Get-Content .\marts\mart_customer_ltv.sql | docker compose exec -T postgres psql -U de_user -d de_sql_practice
```

## Debugging Workflow

When a metric is wrong:

1. Identify the expected grain.
2. Count rows and distinct business keys before each join.
3. Check duplicate keys in dimensions.
4. Check whether order-level metrics are repeated after joining item-level tables.
5. Reconcile source totals against target totals.
6. Check cancelled/refunded business rules.
7. Check late-arriving data and watermark logic.

## Interview Preparation Workflow

Use the `interview/` folder like a mock interview:

1. Open one broken SQL file.
2. Explain the intended business metric.
3. Predict the failure mode.
4. Write diagnostic queries.
5. Fix the SQL.
6. Compare with `solutions/`.

You should be able to explain:

- why the original query is wrong
- how you proved it
- how your fix preserves grain
- what quality check would prevent regression

