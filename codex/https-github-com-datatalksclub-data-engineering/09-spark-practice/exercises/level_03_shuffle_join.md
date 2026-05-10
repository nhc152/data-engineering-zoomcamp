# Level 03 - Shuffle and Join Strategy

## Goal

Learn why joins and aggregations create shuffle, and when broadcast join helps.

## Tasks

1. Run `src/04_join_strategy.py`.
2. Inspect physical plans.
3. Identify broadcast join in the plan.
4. Explain why products is safe to broadcast in this lab.
5. Explain when broadcast join becomes dangerous.

## Expected Learning

- Large-to-large join usually shuffles.
- Small dimension table can be broadcast.
- Broadcast is not safe if the "small" table is actually large.

## Interview Question

How do you decide whether to broadcast a table?

