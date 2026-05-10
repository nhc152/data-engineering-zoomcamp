-- Better dashboard query: dashboard hits a pre-aggregated mart.
-- Trade-off: mart must be refreshed and monitored for freshness.

select
    event_date,
    event_name,
    event_count
from `PROJECT.DATASET.mart_daily_event_counts`
where event_date between date '2026-05-01' and date '2026-05-31';

