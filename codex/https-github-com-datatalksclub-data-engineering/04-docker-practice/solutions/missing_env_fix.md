# Solution - Missing Env Fix

## Problem

The broken Compose file omits:

```yaml
DATABASE_PASSWORD
```

The Python app fails fast because required configuration is missing.

## Fix

Provide the variable:

```yaml
DATABASE_PASSWORD: de_password
```

## Production Lesson

Failing fast is better than silently connecting to the wrong database or using an empty password. Production pipelines should validate required config at startup.

