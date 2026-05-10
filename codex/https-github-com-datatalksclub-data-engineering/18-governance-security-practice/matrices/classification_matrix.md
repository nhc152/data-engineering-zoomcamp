# Ecommerce Classification Matrix

| Table | Column | Classification | Reason | Default Exposure |
|---|---|---|---|---|
| raw.customers | customer_id | Internal | business identifier | allowed in curated |
| raw.customers | full_name | Restricted | PII | masked |
| raw.customers | email | Restricted | PII | masked/tokenized |
| raw.customers | phone | Restricted | PII | masked |
| raw.customers | address | Restricted | PII | hidden or coarse geography |
| raw.customers | country | Internal | low sensitivity | allowed |
| raw.orders | order_id | Internal | business identifier | allowed |
| raw.orders | customer_id | Internal | join key | allowed in curated with governance |
| raw.orders | order_amount | Confidential | business-sensitive revenue | finance/approved groups |
| raw.orders | order_status | Internal | operational status | allowed |
| raw.payments | payment_id | Confidential | payment transaction identifier | restricted curated |
| raw.payments | card_last4 | Restricted | payment-related data | hidden unless approved |
| raw.payments | payment_amount | Confidential | financial metric | finance/approved groups |
| marts.customer_ltv | lifetime_value | Confidential | sensitive business metric | approved analytics |
| marts.daily_revenue | recognized_revenue | Confidential | financial KPI | approved analytics |

## Review Questions

- Does this column identify a person?
- Could this column harm customers or business if leaked?
- Does this column enable joining to PII?
- Is this column necessary for the consumer's use case?

