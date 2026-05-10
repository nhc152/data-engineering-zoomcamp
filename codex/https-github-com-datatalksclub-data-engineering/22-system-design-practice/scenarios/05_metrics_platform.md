# Scenario 05 - Metrics Platform

## Prompt

Design a metrics platform so finance, product, marketing, and executives use consistent definitions for revenue, active users, conversion rate, and customer LTV.

## Requirements To Clarify

- Who owns metric definitions?
- Which metrics are critical?
- Which tools consume metrics?
- Do metrics need versioning?
- How are changes approved?
- What latency is required?
- What happens when definitions change?

## Suggested Assumptions

- Warehouse facts and dimensions already exist.
- BI dashboards, experiments, and reverse ETL all consume metrics.
- Finance metrics require approval workflow.
- Metrics must be documented and tested.

## Deliverables

Design:

- metric definition layer
- semantic layer or metrics store
- ownership workflow
- tests
- lineage
- versioning
- backfill strategy

