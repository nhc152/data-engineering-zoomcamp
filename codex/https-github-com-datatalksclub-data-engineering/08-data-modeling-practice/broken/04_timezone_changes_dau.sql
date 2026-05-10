-- Broken scenario: DAU differs depending on timezone.

-- UTC DAU.
select
    event_date_utc as reporting_date,
    count(distinct customer_id) as dau_utc
from fct_events
where event_name in ('page_view', 'add_to_cart', 'checkout', 'purchase')
group by event_date_utc;

-- VN local DAU.
select
    event_date_vn as reporting_date,
    count(distinct customer_id) as dau_vn
from fct_events
where event_name in ('page_view', 'add_to_cart', 'checkout', 'purchase')
group by event_date_vn;

-- Diagnostic:
-- Events near midnight UTC are likely to move to next local date.
select
    event_id,
    customer_id,
    event_timestamp_utc,
    event_date_utc,
    event_date_vn
from fct_events
where event_date_utc <> event_date_vn;

