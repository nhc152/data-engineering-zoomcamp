# Solution - Volume Fix

## Problem

Without a named volume, database state is tied to the container filesystem. Removing the container removes the data.

## Fix

Use a named volume:

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## Init Script Lesson

Postgres init scripts in `/docker-entrypoint-initdb.d` run only when the data directory is empty. If the named volume already exists, changing init SQL does not re-run it.

To reset local lab intentionally:

```bash
docker compose down -v
docker compose up --build
```

## Production Lesson

Volumes are persistent state. Treat destructive volume commands carefully.

