-- Replace PROJECT_ID, RAW_DATASET, and GCS_BUCKET before running.
-- External tables read directly from GCS.

create or replace external table `PROJECT_ID.RAW_DATASET.ext_customers`
options (
  format = 'CSV',
  uris = ['gs://GCS_BUCKET/raw/ecommerce/customers/ingestion_date=2026-05-01/*.csv'],
  skip_leading_rows = 1,
  autodetect = true
);

create or replace external table `PROJECT_ID.RAW_DATASET.ext_orders`
options (
  format = 'CSV',
  uris = ['gs://GCS_BUCKET/raw/ecommerce/orders/ingestion_date=2026-05-01/*.csv'],
  skip_leading_rows = 1,
  autodetect = true
);

create or replace external table `PROJECT_ID.RAW_DATASET.ext_order_items`
options (
  format = 'CSV',
  uris = ['gs://GCS_BUCKET/raw/ecommerce/order_items/ingestion_date=2026-05-01/*.csv'],
  skip_leading_rows = 1,
  autodetect = true
);

create or replace external table `PROJECT_ID.RAW_DATASET.ext_payments`
options (
  format = 'CSV',
  uris = ['gs://GCS_BUCKET/raw/ecommerce/payments/ingestion_date=2026-05-01/*.csv'],
  skip_leading_rows = 1,
  autodetect = true
);

