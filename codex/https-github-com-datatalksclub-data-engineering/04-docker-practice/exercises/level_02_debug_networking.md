# Level 02 - Debug Networking

## Goal

Understand why `localhost` fails inside a container.

## Broken Config

Use:

```bash
docker compose -f broken/docker-compose.localhost.yml up --build
```

## Expected Failure

The pipeline attempts to connect to `localhost:5432` from inside the pipeline container. That points to the pipeline container itself, not the Postgres container.

## Debug Commands

```bash
docker compose -f broken/docker-compose.localhost.yml ps
docker compose -f broken/docker-compose.localhost.yml logs pipeline
```

## Fix

Read:

```text
solutions/networking_fix.md
```

## Interview Answer

In Docker Compose, containers are on a shared network and can resolve each other by service name. A pipeline container should connect to `postgres:5432`, not `localhost:5432`.

