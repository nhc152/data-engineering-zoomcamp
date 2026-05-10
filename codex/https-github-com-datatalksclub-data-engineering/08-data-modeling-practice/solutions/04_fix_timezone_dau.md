# Solution - Timezone-Safe DAU

## Problem

UTC DAU and Vietnam local DAU can differ for events near midnight.

## Fix

Define reporting timezone explicitly.

For Vietnam reporting:

```text
event_date_vn = date(event_timestamp_utc + 7 hours)
```

Use `mart_daily_active_users_vn` for dashboards serving Vietnam business users.

## Prevention

- Every date metric must document timezone.
- Store original timestamp in UTC.
- Derive reporting dates intentionally.
- Do not let dashboards cast timestamp to date independently.

