# Broken Scenario 03 - Service Account Has Too Much Permission

## Symptom

The lab works, but the service account has project `Owner` or `Editor`.

## Why This Is Dangerous

The pipeline can:

- Delete datasets.
- Modify IAM.
- Read data it should not access.
- Write to production locations by mistake.

## Diagnostic

```bash
gcloud projects get-iam-policy "$GCP_PROJECT_ID" \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:$SERVICE_ACCOUNT_EMAIL"
```

## Expected Fix

Use least privilege:

- `roles/bigquery.jobUser`
- dataset-level `roles/bigquery.dataEditor`
- bucket-level `roles/storage.objectAdmin` for this lab only

For production, split loader and transformer service accounts.

