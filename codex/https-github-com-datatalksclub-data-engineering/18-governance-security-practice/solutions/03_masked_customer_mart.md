# Solution - Masked Customer Mart

## Purpose

Provide useful customer analytics without exposing raw PII.

## Example Columns

```text
customer_id
customer_token
masked_email
country
customer_segment
signup_month
is_active
```

## Masking Examples

```text
alice@example.com -> a***@example.com
0901234567 -> ******4567
```

## Policy

- Raw email remains in Restricted raw/customer dataset.
- Broad analytics access uses masked mart.
- Direct email access requires approval and expiration.

