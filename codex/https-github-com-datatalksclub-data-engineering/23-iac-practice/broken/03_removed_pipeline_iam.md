# Broken Scenario 03 - IAM Binding Removed Pipeline Access

## Symptom

Pipeline starts failing:

```text
Access Denied: BigQuery BigQuery: Permission denied while getting Drive credentials.
```

or:

```text
403: Access Denied: Table ... User does not have permission.
```

## Likely Cause

Terraform apply removed or replaced an IAM binding used by the runtime service account.

## Diagnostic

1. Identify runtime service account.
2. Check IAM policy.
3. Check dataset-level access.
4. Check recent Terraform apply.

## Required Response

Restore least-privilege binding through Terraform, not manual console changes unless emergency.

