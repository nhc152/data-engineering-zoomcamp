# Infrastructure as Code Practice Lab

## Goal

Practice Terraform/IaC design for a GCP data platform:

```text
GCS buckets
BigQuery datasets
service accounts
IAM bindings
lifecycle policies
labels
remote state
drift detection
plan review
cost controls
```

This lab uses realistic Terraform examples with placeholder project IDs. It is safe to commit because it contains no real secrets and no real project identifiers.

## What You Will Learn

- How to structure Terraform for data platform resources.
- How to separate environments: dev and prod.
- How to create reusable modules.
- How to manage GCS buckets with lifecycle and versioning.
- How to create BigQuery datasets with labels and expiration policies.
- How to create pipeline service accounts.
- How to bind IAM with least privilege.
- How to review Terraform plans safely.
- How to detect and respond to drift.
- How to avoid destructive applies.

## Folder Structure

```text
23-iac-practice/
  README.md
  terraform/
    envs/
      dev/
      prod/
    modules/
      gcs_bucket/
      bigquery_dataset/
      service_account/
      iam_binding/
      gcs_bucket_iam_member/
      bigquery_dataset_iam_member/
  policies/
  docs/
  exercises/
  broken/
  solutions/
```

## Safety Rules

Do not run `terraform apply` against a real project until you:

1. Replace placeholder values deliberately.
2. Review `terraform plan`.
3. Confirm no critical resource is being destroyed.
4. Confirm IAM roles are least privilege.
5. Confirm bucket public access is prevented.
6. Confirm environment is dev, not prod.

## Recommended Workflow

```bash
cd terraform/envs/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars.example
```

For this lab, `terraform.tfvars.example` contains fake placeholders. Copy it to `terraform.tfvars` only in your local environment and fill your own learning project values.

## Environment Model

Dev:

- Lower retention.
- Sandbox data only.
- Smaller blast radius.
- Can be recreated.

Prod:

- Stronger retention.
- Stricter IAM.
- `prevent_destroy` on critical buckets.
- Longer table expiration or no expiration for marts.
- Apply only through reviewed process.

## Resources Modeled

- Raw bucket.
- Staging bucket.
- Curated bucket.
- Temp bucket.
- BigQuery raw dataset.
- BigQuery staging dataset.
- BigQuery marts dataset.
- Pipeline loader service account.
- Transformer service account.
- IAM bindings.
- Labels for owner, environment, cost center, managed_by.

## Plan Review Checklist

Before every apply:

- Are there any `destroy` actions?
- Are there any `replace` actions?
- Is any production bucket/dataset affected?
- Are IAM roles too broad?
- Is any bucket public?
- Are lifecycle rules correct?
- Are labels present?
- Is the target project/environment correct?
- Is remote state configured?
- Is the plan generated from the latest main branch?

See:

```text
docs/plan_review_checklist.md
```

## Failure Scenarios

This lab includes scenarios for:

- Terraform plan wants to destroy production bucket.
- Manual change causes drift.
- IAM binding removed pipeline access.
- Dev writes to prod bucket.
- Public bucket risk.
- State lock stuck.

See:

```text
broken/
solutions/
```

## GitHub Deliverables

Your final IaC lab should include:

- Terraform module structure.
- Environment examples.
- IAM matrix.
- Plan review checklist.
- Drift response runbook.
- Cost control notes.
- Failure scenario writeups.
