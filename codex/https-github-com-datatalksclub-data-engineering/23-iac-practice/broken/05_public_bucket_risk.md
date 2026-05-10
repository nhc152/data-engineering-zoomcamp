# Broken Scenario 05 - Public Bucket Risk

## Symptom

Plan adds public IAM member:

```text
member = "allUsers"
```

or disables public access prevention.

## Risk

Raw data may include PII or business-sensitive data. Public exposure is a security incident.

## Required Response

Reject the plan.

Required settings:

```hcl
public_access_prevention    = "enforced"
uniform_bucket_level_access = true
```

