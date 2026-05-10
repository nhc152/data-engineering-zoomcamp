# Retry Policy Notes

## Good Retry Candidates

- Temporary API/network failure.
- Temporary warehouse error.
- Lock/contention.
- Short-lived dependency unavailable.

## Bad Retry Candidates

- SQL syntax error.
- Missing required column.
- Invalid business status.
- Failed data quality check.
- Permission error.

## Retry Storm Prevention

- Limit max attempts.
- Use exponential backoff or longer constant delay.
- Cap concurrency.
- Use circuit breaker/manual pause when upstream is down.
- Alert owner instead of hammering upstream.

## Rule

Before enabling retry, ask:

```text
If this task runs twice, can it create duplicate data or duplicate side effects?
```

