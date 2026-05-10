# Broken Scenario 01 - Plan Wants to Destroy Production Bucket

## Symptom

Terraform plan shows:

```text
- destroy google_storage_bucket.prod_raw
```

or:

```text
-/+ replace google_storage_bucket.prod_raw
```

## Why This Is Dangerous

Production raw bucket may contain source-of-truth data for replay, audit, and recovery. Destroying it can permanently remove the ability to reprocess history.

## Likely Causes

- Resource renamed without `moved` block.
- State file missing or corrupted.
- Bucket name changed.
- Module address changed.
- Someone imported resource incorrectly.

## Required Response

Stop. Do not apply.

