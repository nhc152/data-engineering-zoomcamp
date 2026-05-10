# Solution - Public Bucket with PII Response

## Immediate Actions

1. Disable public access.
2. Preserve audit logs.
3. Identify exposed objects.
4. Determine exposure window.
5. Notify security/privacy owner.
6. Rotate credentials if any secrets were exposed.

## Follow-up

- Enforce public access prevention.
- Add bucket policy check.
- Classify raw bucket as Restricted.
- Require review before external sharing.
- Add alert for public IAM grants.

## Prevention Control

No raw Restricted bucket can be public. This should be enforced by policy and reviewed in IaC.

