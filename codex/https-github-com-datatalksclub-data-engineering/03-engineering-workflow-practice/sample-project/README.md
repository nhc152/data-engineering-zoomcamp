# Sample Data Pipeline Project

## Purpose

This small project exists only for Git/Linux workflow practice. It simulates a data pipeline repo with SQL, logs, sample data, and runbook.

## Data Flow

```text
data/raw/orders.csv
    -> sql/stg_orders.sql
    -> dbt/models/marts/fct_orders.sql
    -> data/processed/
```

## Setup

Copy environment template:

```bash
cp .env.example .env
```

Inspect sample data:

```bash
head -n 5 data/raw/orders.csv
```

Inspect logs:

```bash
tail -n 50 logs/sample_pipeline.log
grep -n "ERROR" logs/sample_pipeline.log
```

Run helper script:

```bash
bash scripts/inspect_logs.sh
```

On PowerShell:

```powershell
.\scripts\inspect_logs.ps1
```

## Validation

Before opening a PR, run:

```bash
git status
git diff
bash scripts/inspect_logs.sh
```

On PowerShell:

```powershell
git status
git diff
.\scripts\inspect_logs.ps1
```

## Data Model Grain

- `sql/stg_orders.sql`: one row per order after cleaning raw order rows.
- `dbt/models/marts/fct_orders.sql`: one row per order with recognized revenue.

## Operational Notes

- Do not commit `.env`.
- Do not commit generated files in `data/processed/`.
- PRs that change revenue logic must include data impact and rollback plan.
