# dbt Practice Lab

## Goal

Build a portfolio-grade dbt project that transforms ecommerce raw tables into tested, documented marts.

Target flow:

```text
PostgreSQL raw tables
  -> dbt sources
  -> staging views
  -> intermediate models
  -> marts
  -> generic tests
  -> singular reconciliation tests
  -> snapshots
  -> docs and lineage
```

This lab is intentionally production-minded. It is not just "create a model and run dbt". You will practice lineage, tests, incremental logic, broken scenarios, and debugging.

## What You Will Learn

- dbt project structure.
- `source()` and `ref()`.
- Staging/intermediate/marts layering.
- Generic tests.
- Singular reconciliation tests.
- Documentation and lineage.
- Incremental model with watermark/lookback.
- Snapshot for slowly changing dimensions.
- Macro for reusable status normalization.
- CI-ready commands.
- Anti-patterns: hard-coded tables, broken lineage, weak tests, nested views, unsafe incremental filters.

## Prerequisites

Install locally:

- Docker Desktop.
- Python 3.11+.
- dbt adapter for Postgres.

Recommended Python setup:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

On PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Start PostgreSQL

```bash
docker compose up -d
```

This creates a local PostgreSQL database and loads raw ecommerce tables into schema `raw`.

Connection:

```text
host: localhost
port: 5432
database: dbt_practice
user: dbt_user
password: dbt_password
```

## Configure dbt Profile

Copy the profile example:

```bash
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
```

On Windows PowerShell:

```powershell
mkdir $HOME\.dbt
Copy-Item .\profiles.yml.example $HOME\.dbt\profiles.yml
```

## Recommended Run Order

```bash
dbt debug
dbt parse
dbt deps
dbt seed
dbt build
dbt docs generate
dbt docs serve
```

Useful commands:

```bash
dbt run --select staging
dbt build --select marts
dbt test --select marts
dbt build --select fct_orders+
dbt ls --select +mart_daily_revenue
dbt compile --select fct_orders
```

## Project Architecture

```text
raw.customers
raw.products
raw.orders
raw.order_items
raw.payments
      |
      v
staging.stg_ecommerce__*
      |
      v
intermediate.int_*_aggregated_to_order
      |
      v
marts.dim_customers
marts.dim_products
marts.fct_orders
marts.mart_daily_revenue
marts.mart_customer_ltv
```

## Folder Structure

```text
07-dbt-practice/
  README.md
  docker-compose.yml
  dbt_project.yml
  profiles.yml.example
  requirements.txt
  init/
  models/
    staging/
    intermediate/
    marts/
  tests/
  snapshots/
  macros/
  seeds/
  analyses/
  exercises/
  broken/
  solutions/
```

## Model Grain

| Model | Grain |
|---|---|
| `stg_ecommerce__customers` | one row per current customer |
| `stg_ecommerce__orders` | one row per latest order version |
| `stg_ecommerce__order_items` | one row per order item |
| `stg_ecommerce__payments` | one row per payment |
| `int_order_items__aggregated_to_order` | one row per order |
| `int_payments__aggregated_to_order` | one row per order |
| `dim_customers` | one row per current customer |
| `dim_products` | one row per product |
| `fct_orders` | one row per order |
| `mart_daily_revenue` | one row per order date |
| `mart_customer_ltv` | one row per customer |

## Data Quality Strategy

Generic tests:

- unique primary keys.
- not null keys.
- accepted order/payment statuses.
- relationships between facts and dimensions.

Singular tests:

- payment and item total reconciliation.
- recognized revenue cannot be negative for non-refunded orders.

Source freshness:

- raw source tables use `loaded_at`.

## Broken Scenarios

Study these after a successful `dbt build`:

- `broken/hardcoded_table_breaks_lineage.sql`
- `broken/incremental_misses_late_update.sql`
- `broken/uniqueness_test_fails.md`
- `broken/accepted_values_test_fails.md`
- `broken/nested_views_slow.md`
- `broken/source_schema_changes.md`

Compare with `solutions/`.

## CI-Ready Commands

For a basic CI job:

```bash
dbt deps
dbt parse
dbt build --select state:modified+ --defer --state path/to/prod/artifacts
```

For this local lab without state artifacts:

```bash
dbt parse
dbt build
```

## GitHub Deliverables

Your finished lab should show:

- clean dbt project structure.
- models using `source()` and `ref()`.
- meaningful tests.
- generated docs/lineage screenshots.
- broken scenarios and fixes.
- README explaining architecture, grain, tests, and failure handling.

