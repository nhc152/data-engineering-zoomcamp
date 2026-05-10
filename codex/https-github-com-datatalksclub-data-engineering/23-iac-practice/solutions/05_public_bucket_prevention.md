# Solution 05 - Public Bucket Prevention

Required bucket settings:

```hcl
uniform_bucket_level_access = true
public_access_prevention    = "enforced"
```

Plan review must reject:

- `allUsers`
- `allAuthenticatedUsers`
- disabled public access prevention
- object ACL-based sharing

Production response if public exposure happened:

1. Remove public access.
2. Identify exposed objects.
3. Check access logs.
4. Notify security/legal if PII.
5. Rotate affected secrets if any.
6. Write postmortem.

