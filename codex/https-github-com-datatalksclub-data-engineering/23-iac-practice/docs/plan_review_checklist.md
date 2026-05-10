# Terraform Plan Review Checklist

Before approving a Terraform plan, answer these questions.

## Destructive Changes

- Does the plan contain `destroy`?
- Does the plan contain `replace`?
- Is any bucket, dataset, service account, or IAM binding affected?
- Could this cause data loss?
- Is `prevent_destroy` configured for critical resources?

## Environment

- Is this dev, staging, or prod?
- Is the project ID correct?
- Is the backend state path correct?
- Is the operator/apply identity correct?

## IAM

- Are new roles least privilege?
- Any `roles/owner` or `roles/editor`?
- Any public bucket access?
- Any broad project-level role that should be dataset/bucket-level?

## Cost

- Are labels present?
- Are lifecycle rules appropriate?
- Are temp resources expiring?
- Are dev resources smaller/cheaper than prod?

## Governance

- Are raw/staging/marts separated?
- Does BI access only marts?
- Are PII datasets protected?
- Are audit-sensitive resources retained?

## Approval Rule

Reject the plan if:

- It destroys production data resources unexpectedly.
- It grants owner/editor to pipeline accounts.
- It makes buckets public.
- It applies prod changes from a laptop without approval.

