# Scenario 01 - Ecommerce Warehouse

## Prompt

Design a data warehouse for an ecommerce company. The business needs daily revenue, customer LTV, product performance, and refund reporting.

## Requirements To Clarify

- How many orders per day?
- How many payment/refund events?
- Is daily reporting enough?
- What time must dashboards be ready?
- Do refunds update old orders?
- Are customers/products mutable?
- Does data contain PII?
- How far back do we need to backfill?

## Suggested Assumptions

- 1 million orders/day.
- 3 million order item rows/day.
- 1.2 million payment/refund events/day.
- Dashboard ready by 8 AM.
- Finance correctness is high priority.
- Data retained for 3 years.

## Deliverables

Write an answer using:

- requirement clarification
- volume estimation
- architecture
- bottlenecks
- failure modes
- cost
- data quality
- trade-offs

