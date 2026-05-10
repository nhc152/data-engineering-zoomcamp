# Broken Scenario 02 - Analyst Gets Raw Access Unnecessarily

## Symptom

An analyst requests raw customer data to build a dashboard.

## Problem

Raw data contains Restricted PII. Dashboard only needs customer segment and country.

## Better Decision

Provide a curated masked mart:

```text
marts.customer_segments
  customer_id
  country
  customer_segment
  signup_month
```

Do not expose:

- email
- phone
- full address
- raw event payloads

## Governance Lesson

Self-service should happen through curated datasets, not unrestricted raw access.

