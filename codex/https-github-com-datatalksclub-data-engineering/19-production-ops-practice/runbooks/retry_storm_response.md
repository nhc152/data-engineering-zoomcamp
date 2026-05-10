# Runbook - Retry Storm Response

## Symptom

Many tasks retry repeatedly and overload an upstream API, warehouse, or queue.

## Immediate Response

1. Pause or throttle the pipeline.
2. Check retry policy and task count.
3. Check upstream health.
4. Check whether retries are creating side effects.
5. Notify owner if SLA is at risk.

## Common Causes

- Upstream API outage.
- Too many parallel tasks.
- Retry delay too short.
- No exponential backoff.
- Deterministic bug incorrectly marked retryable.

## Mitigation

- Pause DAG/flow.
- Reduce concurrency.
- Increase retry delay.
- Disable retries for deterministic failures.
- Add circuit breaker pattern if applicable.

## Prevention

- Retry only transient errors.
- Use exponential backoff with jitter.
- Set max attempts.
- Use pools/concurrency limits.
- Make writes idempotent.
- Alert after repeated failures, not every failed attempt.

