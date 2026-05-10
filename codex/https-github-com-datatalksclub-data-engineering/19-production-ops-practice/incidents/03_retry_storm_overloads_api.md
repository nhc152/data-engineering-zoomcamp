# Incident 03 - Retry Storm Overloads API

## Timeline

```text
01:00 Upstream API began returning 503
01:02 80 extract tasks started retrying every 30 seconds
01:10 API latency worsened
01:20 Source team reported overload
01:30 Data Engineering paused pipeline
02:10 API recovered
02:30 Pipeline resumed with reduced concurrency
```

## Impact

Source API outage lasted longer because pipeline retries added load.

## Root Cause

Retry policy used short fixed delay and high concurrency.

## Detection Gap

No retry storm alert or concurrency limit.

## Immediate Fix

Paused pipeline and reduced concurrency.

## Prevention

- Exponential backoff with jitter.
- Max attempts.
- API pool/concurrency cap.
- Circuit breaker.
- Retry only transient errors.

