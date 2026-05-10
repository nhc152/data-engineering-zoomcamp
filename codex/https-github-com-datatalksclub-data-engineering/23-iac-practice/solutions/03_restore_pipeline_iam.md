# Solution 03 - Restore Pipeline IAM

## Steps

1. Identify service account used by failing pipeline.
2. Identify missing permission.
3. Add least-privilege binding in Terraform.
4. Run plan.
5. Review scope: project, dataset, or bucket.
6. Apply.
7. Rerun pipeline.

## Do Not

- Add `roles/editor`.
- Fix only in console and leave Terraform stale.
- Grant raw access to BI users.

