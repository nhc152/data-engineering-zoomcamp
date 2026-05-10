# Level 04 - PostgreSQL Load

Goal: load records into PostgreSQL idempotently.

Tasks:

1. Start PostgreSQL.
2. Run CSV ingestion twice.
3. Query `orders`.
4. Query `pipeline_runs`.
5. Explain why row count does not double.

Commands:

```powershell
docker compose up -d postgres
python -m src.main --source csv --input-path data/sample/orders.csv --run-date 2026-05-09 --run-id csv_test
python -m src.main --source csv --input-path data/sample/orders.csv --run-date 2026-05-09 --run-id csv_test
docker compose exec postgres psql -U de_user -d python_practice -c "select order_id, amount, status from orders order by order_id;"
```

