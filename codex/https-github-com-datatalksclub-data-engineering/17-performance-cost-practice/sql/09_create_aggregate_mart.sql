-- Example aggregate mart.
-- Trade-off: extra storage and refresh job, but lower repeated serving cost.

create or replace table `PROJECT.DATASET.mart_daily_event_counts`
partition by event_date
cluster by event_name
as
select
    date(event_timestamp) as event_date,
    event_name,
    count(*) as event_count,
    current_timestamp() as mart_loaded_at
from `PROJECT.DATASET.raw_events`
group by event_date, event_name;

