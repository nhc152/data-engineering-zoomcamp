# Policy - No Public Buckets

## Rule

No GCS bucket should allow public access.

Required Terraform setting:

```hcl
public_access_prevention = "enforced"
uniform_bucket_level_access = true
```

## Review Check

Reject a plan if:

- Bucket has public IAM member like `allUsers` or `allAuthenticatedUsers`.
- `public_access_prevention` is missing or not enforced.

## Why

Raw buckets often contain PII, financial data, event logs, and operational data. Public access is a critical incident.

