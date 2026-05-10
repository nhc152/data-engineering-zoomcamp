# Level 01 - Setup GCP, GCS, and BigQuery

## Goal

Create a learning cloud warehouse environment without exposing credentials.

## Tasks

1. Create or choose a GCP learning project.
2. Enable billing with a low budget alert.
3. Install and authenticate Google Cloud SDK.
4. Create one GCS bucket.
5. Create three BigQuery datasets:
   - raw
   - staging
   - marts
6. Upload sample CSV files to the raw GCS layout.

## Expected Output

You can list files:

```bash
gcloud storage ls "gs://$GCS_BUCKET/raw/ecommerce/orders/ingestion_date=2026-05-01/"
```

You can list datasets:

```bash
bq ls "$GCP_PROJECT_ID:"
```

## Questions

- What is the project boundary?
- Why should bucket and dataset location match?
- Why should raw files be append-only?

