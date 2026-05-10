# Docker Practice Lab

## Goal

Lab nay giup ban luyen Docker cho Data Engineering theo cach production-first:

```text
local CSV file
    -> Python pipeline container
    -> PostgreSQL container
    -> persistent named volume
    -> SQL quality checks
```

Day khong phai Docker tutorial chung chung. Lab tap trung vao nhung loi Data Engineer gap that:

- App container dung sai `localhost`.
- Database chua ready.
- Thieu environment variable.
- Port conflict.
- Volume bi xoa hoac init SQL khong chay lai.
- Dockerfile build cham do layer order sai.

## Architecture

```text
Host machine
  |
  | bind mount ./data -> /app/data
  v
pipeline container
  |
  | Docker Compose network, host=postgres, port=5432
  v
postgres container
  |
  | named volume
  v
postgres_data
```

## What You Will Learn

- Dockerfile cho Python pipeline.
- Docker Compose cho local data platform.
- PostgreSQL container voi persistent volume.
- Service networking: `postgres` vs `localhost`.
- Environment variables.
- Healthchecks.
- Container logs.
- `docker compose exec`.
- Reset volume local co chu dich.
- Debug broken configs.
- Image build hygiene.

## Prerequisites

- Docker Desktop hoac Docker Engine.
- Docker Compose V2.
- Optional: `psql` tren host. Khong bat buoc vi co the dung `docker compose exec`.

Check:

```bash
docker --version
docker compose version
```

## Folder Structure

```text
04-docker-practice/
  docker-compose.yml
  Dockerfile
  .dockerignore
  .env.example
  requirements.txt
  README.md
  data/
    orders.csv
  src/
    de_pipeline/
      __init__.py
      config.py
      db.py
      main.py
  sql/
    init/
      00_schema.sql
    quality_checks.sql
  exercises/
    level_01_run_lab.md
    level_02_debug_networking.md
    level_03_debug_env_and_healthcheck.md
    level_04_volumes_and_init.md
    level_05_image_build_hygiene.md
  broken/
    docker-compose.localhost.yml
    docker-compose.missing-env.yml
    docker-compose.no-healthcheck.yml
    docker-compose.port-conflict.yml
    Dockerfile.slow
    docker-compose.no-volume.yml
  solutions/
    networking_fix.md
    missing_env_fix.md
    healthcheck_fix.md
    port_conflict_fix.md
    volume_fix.md
    dockerfile_build_fix.md
```

## Quick Start

From this folder:

```bash
docker compose up --build
```

Expected result:

- `postgres` starts and becomes healthy.
- `pipeline` waits for Postgres healthcheck.
- `pipeline` reads `data/orders.csv`.
- `pipeline` upserts records into `raw.orders`.
- `pipeline` prints loaded row count.

The pipeline exits successfully after loading data. PostgreSQL keeps running.

Check containers:

```bash
docker compose ps
```

Inspect logs:

```bash
docker compose logs postgres
docker compose logs pipeline
```

Connect to PostgreSQL from container:

```bash
docker compose exec postgres psql -U de_user -d de_docker_lab
```

Run quality checks:

```bash
docker compose exec -T postgres psql -U de_user -d de_docker_lab < sql/quality_checks.sql
```

PowerShell alternative:

```powershell
Get-Content .\sql\quality_checks.sql | docker compose exec -T postgres psql -U de_user -d de_docker_lab
```

Query loaded data:

```bash
docker compose exec postgres psql -U de_user -d de_docker_lab -c "select * from raw.orders order by order_id;"
```

## Environment Variables

The Compose file provides defaults:

```text
POSTGRES_USER=de_user
POSTGRES_PASSWORD=de_password
POSTGRES_DB=de_docker_lab
DATABASE_HOST=postgres
DATABASE_PORT=5432
INPUT_FILE=/app/data/orders.csv
```

For local customization, copy:

```bash
cp .env.example .env
```

Do not commit real `.env` files.

## Important Networking Lesson

Inside the `pipeline` container:

```text
localhost = the pipeline container itself
postgres = the PostgreSQL service container
```

So this is wrong inside Compose:

```text
DATABASE_HOST=localhost
```

This is correct:

```text
DATABASE_HOST=postgres
```

Host port mapping like `"5432:5432"` is for tools on your laptop connecting to Postgres. Container-to-container traffic uses the internal Compose network and service name.

## Volume Lesson

Postgres data is stored in a named volume:

```yaml
volumes:
  postgres_data:
```

This means:

- Stopping/removing containers does not delete database data.
- Init SQL runs only when the volume is first created.
- If you change `sql/init/00_schema.sql`, it will not re-run while the old volume exists.

Reset local lab intentionally:

```bash
docker compose down -v
docker compose up --build
```

Do not run `down -v` casually when you care about data.

## Debugging Workflow

### Container crashed

```bash
docker compose ps
docker compose logs pipeline
```

Check:

- Exit code.
- Missing env var.
- Wrong command.
- File path not found.
- Dependency import error.

### App cannot connect database

Checklist:

1. Is Postgres healthy?
2. Is `DATABASE_HOST=postgres`?
3. Is `DATABASE_PORT=5432`?
4. Are user/password/database correct?
5. Did app start before DB was ready?

Commands:

```bash
docker compose ps
docker compose logs postgres
docker compose exec pipeline sh
```

Inside container:

```bash
env
python -c "import socket; print(socket.gethostbyname('postgres'))"
```

### Port conflict

Symptom:

```text
Bind for 0.0.0.0:5432 failed: port is already allocated
```

Fix:

```yaml
ports:
  - "5433:5432"
```

Host tools connect to port `5433`. Containers still connect to `postgres:5432`.

## Exercises

Follow these in order:

1. [Level 01 - Run Lab](./exercises/level_01_run_lab.md)
2. [Level 02 - Debug Networking](./exercises/level_02_debug_networking.md)
3. [Level 03 - Debug Env and Healthcheck](./exercises/level_03_debug_env_and_healthcheck.md)
4. [Level 04 - Volumes and Init](./exercises/level_04_volumes_and_init.md)
5. [Level 05 - Image Build Hygiene](./exercises/level_05_image_build_hygiene.md)

## Broken Configs

Use these files to practice debugging:

- `broken/docker-compose.localhost.yml`
- `broken/docker-compose.missing-env.yml`
- `broken/docker-compose.no-healthcheck.yml`
- `broken/docker-compose.port-conflict.yml`
- `broken/docker-compose.no-volume.yml`
- `broken/Dockerfile.slow`

Run a broken Compose file:

```bash
docker compose -f broken/docker-compose.localhost.yml up --build
```

Then read the matching solution in `solutions/`.

## Expected Database Output

After running the good lab:

```sql
select count(*) from raw.orders;
```

Expected:

```text
5
```

Rerun:

```bash
docker compose up --build pipeline
```

Expected row count should remain `5` because the load uses upsert.

## GitHub Deliverables

When you finish this lab, your repo should show:

- `docker-compose.yml`
- `Dockerfile`
- `.dockerignore`
- `.env.example`
- Python pipeline code
- init SQL
- quality checks
- broken examples
- solutions
- README with debugging workflow
