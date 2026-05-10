# Level 01 - Run the Good Lab

## Goal

Start the local Docker data platform and verify that the Python pipeline loads data into PostgreSQL.

## Steps

1. Start the lab:

```bash
docker compose up --build
```

2. Check services:

```bash
docker compose ps
```

3. Inspect pipeline logs:

```bash
docker compose logs pipeline
```

4. Query loaded data:

```bash
docker compose exec postgres psql -U de_user -d de_docker_lab -c "select count(*) from raw.orders;"
```

5. Run quality checks:

```bash
docker compose exec -T postgres psql -U de_user -d de_docker_lab < sql/quality_checks.sql
```

## Expected Output

- Postgres is healthy.
- Pipeline exits with code 0.
- Row count is 5.
- Duplicate check returns zero rows.

## What You Should Learn

- Compose can run multiple services.
- The app container connects to Postgres by service name.
- Data persists in a named volume.

