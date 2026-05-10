# Solution - Networking Fix

## Problem

The broken Compose file sets:

```yaml
DATABASE_HOST: localhost
```

Inside the `pipeline` container, `localhost` means the `pipeline` container itself. PostgreSQL is running in another container.

## Fix

Use the Compose service name:

```yaml
DATABASE_HOST: postgres
```

## Why This Works

Docker Compose creates a network and registers service names in DNS. The `pipeline` container can resolve `postgres` to the IP of the PostgreSQL container.

## Interview Answer

Host port mapping is for host-to-container connections. Container-to-container connections should use the service name and internal port.

