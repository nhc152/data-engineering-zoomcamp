# Runbook - Access Review

## Cadence

- Raw Restricted datasets: monthly.
- Confidential datasets: quarterly.
- Service accounts: monthly.
- Breakglass access: after every incident.

## Review Steps

1. Export current IAM bindings.
2. Compare against IAM matrix.
3. Identify broad roles.
4. Identify stale users.
5. Identify service accounts with unused permissions.
6. Remove or downgrade access.
7. Document changes.

## Red Flags

- Project Owner assigned to pipeline service account.
- BI users can read raw datasets.
- Temporary access without expiration.
- Unknown user/group with Restricted access.
- Public bucket/object access.

