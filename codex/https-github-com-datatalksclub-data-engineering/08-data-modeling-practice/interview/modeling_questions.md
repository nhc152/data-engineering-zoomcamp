# Data Modeling Interview Questions

## Grain

- What is grain?
- Why should you define grain before joining tables?
- How do you detect join explosion?
- What is the difference between order grain and order-item grain?

## Facts and Dimensions

- What is a fact table?
- What is a dimension table?
- When would you create both `fct_orders` and `fct_order_items`?
- What is a degenerate dimension?

## Star vs Snowflake

- What is star schema?
- What is snowflake schema?
- Why is star schema often better for BI?
- When is snowflake schema acceptable?

## SCD

- What is SCD type 1?
- What is SCD type 2?
- How do you join a fact table to an SCD2 dimension?
- What happens if you join SCD2 only by business key?

## Metrics

- Why can two dashboards show different revenue?
- How do you define recognized revenue?
- Why should product revenue come from item-level fact?
- How should refunds affect LTV?

## Events

- How do you model clickstream events?
- Why does timezone matter for DAU?
- What is event deduplication?

## Senior-Level Answers Should Include

For every answer, mention:

- grain
- source model
- failure mode
- prevention
- trade-off

