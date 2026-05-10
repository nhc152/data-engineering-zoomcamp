# Broken Scenario 01 - Dataset and Bucket Location Mismatch

## Symptom

BigQuery external table or load job fails with a location-related error.

Example:

```text
Cannot read and write in different locations.
```

## Cause

The GCS bucket is in one location, but the BigQuery dataset is in another incompatible location.

Example:

- Bucket: `EU`
- Dataset: `US`

## Diagnostic Steps

```bash
gcloud storage buckets describe "gs://$GCS_BUCKET" --format="value(location)"
bq show --format=prettyjson "$GCP_PROJECT_ID:$BQ_RAW_DATASET"
```

## Fix

Create bucket and datasets in the same location for this lab.

Do not move production data casually. In production, plan migration and downstream impact.

