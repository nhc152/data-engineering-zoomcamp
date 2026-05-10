# Solution Example - Retry Storm Prevention

## Problem

Upstream API returns 503. Pipeline retries many tasks at high frequency, adding load and extending outage.

## Prevention

- Exponential backoff.
- Jitter.
- Max attempts.
- API concurrency pool.
- Circuit breaker.
- Alert after repeated failures, not every failed attempt.
- Separate transient failures from deterministic failures.

## Operational Response

1. Pause or throttle pipeline.
2. Notify source owner.
3. Resume with reduced concurrency.
4. Backfill missing interval after source recovers.
5. Review retry policy.

