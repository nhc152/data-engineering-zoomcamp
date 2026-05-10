# Solution - Healthcheck Fix

## Problem

`depends_on` without healthcheck only starts containers in order. It does not guarantee that Postgres is ready to accept connections.

## Fix

Add a Postgres healthcheck:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U de_user -d de_docker_lab"]
  interval: 5s
  timeout: 5s
  retries: 10
```

Then make pipeline wait for it:

```yaml
depends_on:
  postgres:
    condition: service_healthy
```

## Production Lesson

Startup order is not readiness. Reliable systems need readiness checks and bounded retry in the application.

