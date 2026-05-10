# Level 03 - Debug Env and Healthcheck

## Goal

Practice two common production problems:

- missing required environment variable
- app starts before database is ready

## Broken Configs

Missing env:

```bash
docker compose -f broken/docker-compose.missing-env.yml up --build
```

No healthcheck:

```bash
docker compose -f broken/docker-compose.no-healthcheck.yml up --build
```

## Expected Failures

Missing env:

- Pipeline fails fast with `Missing required environment variable`.

No healthcheck:

- Pipeline may start before Postgres accepts connections.
- This can be flaky: sometimes pass, sometimes fail.

## Fix

Read:

```text
solutions/missing_env_fix.md
solutions/healthcheck_fix.md
```

## What You Should Learn

- Failing fast is better than silently writing to a wrong target.
- `depends_on` without healthcheck does not guarantee service readiness.

