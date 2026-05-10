-- Bad dashboard query: dashboard hits raw events directly.
-- If this runs every minute, cost grows with raw event size and refresh frequency.

select
    date(event_timestamp) as event_date,
    event_name,
    count(*) as event_count
from `PROJECT.DATASET.raw_events`
where date(event_timestamp) between date '2026-05-01' and date '2026-05-31'
group by event_date, event_name;

