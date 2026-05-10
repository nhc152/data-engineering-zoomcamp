# Level 04 - Volumes and Init Scripts

## Goal

Understand persistent volumes and why Postgres init scripts run only once.

## Steps

1. Start the good lab:

```bash
docker compose up --build
```

2. Stop containers without deleting volumes:

```bash
docker compose down
```

3. Start again:

```bash
docker compose up
```

4. Observe data is still present:

```bash
docker compose exec postgres psql -U de_user -d de_docker_lab -c "select count(*) from raw.orders;"
```

5. Reset intentionally:

```bash
docker compose down -v
docker compose up --build
```

## Broken Config

Run:

```bash
docker compose -f broken/docker-compose.no-volume.yml up --build
```

Then remove containers and observe that database state does not persist.

## Fix

Read:

```text
solutions/volume_fix.md
```

