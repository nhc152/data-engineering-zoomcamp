-- Example freshness checks. In production, compare these to SLA thresholds.

select
    'orders latest ingestion' as check_name,
    max(ingestion_timestamp) as latest_ingestion_timestamp,
    now() - max(ingestion_timestamp) as age
from raw.orders;

select
    'payments latest ingestion' as check_name,
    max(ingestion_timestamp) as latest_ingestion_timestamp,
    now() - max(ingestion_timestamp) as age
from raw.payments;

select
    'events latest ingestion' as check_name,
    max(ingestion_timestamp) as latest_ingestion_timestamp,
    now() - max(ingestion_timestamp) as age
from raw.events;

