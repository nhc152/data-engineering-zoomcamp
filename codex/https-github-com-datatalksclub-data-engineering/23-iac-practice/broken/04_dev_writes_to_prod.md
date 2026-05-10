# Broken Scenario 04 - Dev Writes to Prod Bucket

## Symptom

Test data appears in production raw bucket.

## Cause

Dev job used production bucket name or production service account.

## Prevention

- Separate dev/prod service accounts.
- Separate dev/prod projects or buckets.
- Environment-specific config.
- CI checks that block prod targets from dev branches.

## Required Response

1. Stop dev job.
2. Identify contaminated objects.
3. Quarantine/delete if safe.
4. Review access and config.
5. Add guardrail.

