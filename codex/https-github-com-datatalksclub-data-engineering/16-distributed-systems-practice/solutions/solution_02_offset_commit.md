# Solution 02 - Sink Write Before Offset Commit

## Root Cause

The consumer successfully wrote to the sink but crashed before committing offset. On restart, it reads the same offset again.

## Correct Mental Model

This is at-least-once processing. It is not a bug by itself. The bug is a non-idempotent sink.

## Prevention

- idempotent sink keyed by event_id/business key
- processed_events table
- transactional outbox/inbox pattern when suitable
- offset management and replay tests

## Interview Answer

I assume consumers can process the same event more than once. I design the sink so repeated processing updates or ignores the same logical event rather than appending duplicates.

