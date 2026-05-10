# Drift Response Runbook

## What Is Drift?

Drift means real cloud infrastructure no longer matches Terraform code/state.

Common causes:

- Manual console changes.
- Emergency fixes.
- Resource deleted outside Terraform.
- IAM changes outside PR.
- Provider default changes.

## Detection

Run:

```bash
terraform plan -refresh-only
```

or normal plan in a controlled CI job.

## Triage

1. Identify changed resource.
2. Determine whether drift is intended or accidental.
3. Determine risk: security, cost, data loss, pipeline outage.
4. Identify who changed it and why.
5. Decide: update Terraform code or revert real infra.

## Response

If manual change is valid:

- Update Terraform code.
- Run plan.
- Review.
- Apply.

If manual change is invalid:

- Apply Terraform to revert.
- Restrict manual access if needed.
- Document incident.

## Prevention

- Restrict production console access.
- Require PR for changes.
- Run scheduled drift detection.
- Alert on critical IAM/bucket policy drift.

