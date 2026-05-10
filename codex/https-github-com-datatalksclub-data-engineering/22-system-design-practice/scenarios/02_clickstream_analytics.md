# Scenario 02 - Clickstream Analytics

## Prompt

Design a clickstream analytics platform for web and mobile product events. Product managers need funnels, sessions, conversion rate, and DAU/WAU. 15-30 minute latency is acceptable.

## Requirements To Clarify

- Events per user per day?
- Peak event rate?
- Required latency?
- Do events arrive late or out of order?
- Is event schema governed?
- Do we need raw replay?
- How long should raw events be retained?

## Suggested Assumptions

- 5 million daily active users.
- 40 events/user/day.
- Average event size 1 KB.
- Peak multiplier 5x.
- 30 minute latency acceptable.
- Retention 1 year raw, 2 years aggregates.

## Deliverables

Explain whether to use:

- micro-batch
- streaming
- Kappa
- Lambda

Justify the chosen approach.

