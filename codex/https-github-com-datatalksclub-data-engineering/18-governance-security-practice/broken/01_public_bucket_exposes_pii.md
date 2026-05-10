# Broken Scenario 01 - Public Bucket Exposes PII

## Symptom

A raw GCS/S3 bucket containing customer exports is publicly readable.

## Impact

- Customer emails/phones may be exposed.
- Legal/privacy incident.
- Trust and compliance impact.

## Root Cause

- Bucket or object ACL allowed public access.
- No policy preventing public buckets.
- Raw Restricted data stored without guardrails.

## Detection

Check:

- bucket IAM
- object ACLs
- public access prevention settings
- audit logs for access

## Expected Response

1. Block public access immediately.
2. Rotate exposed credentials if any.
3. Preserve audit logs.
4. Identify data exposed.
5. Notify security/legal according to policy.
6. Add prevention control.

