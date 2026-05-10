# Audit Log Policy

## What to Audit

- Dataset/table access.
- Exports/downloads.
- IAM changes.
- Service account key creation.
- Permission grants/removals.
- Admin actions.
- Failed access attempts.
- Public bucket or object ACL changes.

## Minimum Audit Fields

- actor identity
- resource accessed
- action
- timestamp
- source IP/device context if available
- success/failure
- request reason or ticket if privileged

## Review Cadence

- Privileged access: weekly review.
- IAM changes: daily alert or near real-time alert.
- Public exposure changes: immediate alert.
- Raw Restricted access: weekly review.

