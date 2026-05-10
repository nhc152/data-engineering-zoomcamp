# Level 02 - Kestra Flow

## Goal

Run the same pipeline through Kestra.

## Tasks

1. Start Kestra:

```bash
docker compose up -d
```

2. Open:

```text
http://localhost:8080
```

3. Import:

```text
flows/ecommerce_daily_orders.yml
```

4. Execute with:

```text
run_date = 2026-05-01
```

## Expected Output

The flow should run tasks in order and generate the same files as Level 01.

## Questions

- Where do you see task logs?
- How is `run_date` passed?
- What would break if a task used `current_date`?

