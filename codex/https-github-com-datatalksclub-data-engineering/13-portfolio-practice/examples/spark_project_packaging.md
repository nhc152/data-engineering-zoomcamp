# Example Packaging - Spark Project

## Project Summary

Build a Spark batch pipeline:

```text
raw CSV/JSON -> Spark cleaning/dedup -> partitioned Parquet -> aggregate marts
```

## Strong README Angle

This project demonstrates:

- file format decisions
- partitioned output
- Spark joins and shuffle awareness
- skew/small-files notes
- row count logging
- performance debugging mindset

## Good Trade-Offs to Explain

- Spark is useful when data is too large for pandas or needs distributed processing.
- Parquet is better than CSV for analytics because it is columnar and compressed.
- More partitions increase parallelism but too many files hurt downstream query planning.
- Broadcast join is fast for small dimensions but risky if the table is not actually small.

## Failure Story

```text
A realistic failure is a skewed join where one customer_id has most rows. I would detect this through Spark UI stage/task time imbalance and fix it by salting, pre-aggregating, or changing the join strategy.
```

