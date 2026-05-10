# Solution - Port Conflict Fix

## Problem

Two services or one local process try to bind host port `5432`.

## Fix

Change only the host port:

```yaml
ports:
  - "5433:5432"
```

Host tools connect to:

```text
localhost:5433
```

Containers still connect to:

```text
postgres:5432
```

## Production Lesson

Host port and container port are different. Container-to-container traffic does not need the host port mapping.

