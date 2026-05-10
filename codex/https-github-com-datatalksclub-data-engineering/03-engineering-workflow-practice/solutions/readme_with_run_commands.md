# Orders Pipeline

## Purpose

Loads raw orders, creates staging output, and builds order facts.

## Setup

```bash
cp .env.example .env
```

## Run

```bash
bash scripts/inspect_logs.sh
```

## Validate

```bash
head -n 5 data/raw/orders.csv
tail -n 100 logs/sample_pipeline.log
grep -n "ERROR" logs/sample_pipeline.log
```

## Data Impact

- Input: `data/raw/orders.csv`
- Output: `data/processed/`
- Grain: one row per order

## Troubleshooting

See `RUNBOOK.md`.

