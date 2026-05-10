# Level 04 - Spark and Kafka Cost

## Goal

Practice diagnosing distributed processing and streaming cost drivers.

## Tasks

1. Read `broken/03_spark_rerun_doubles_compute.md`.
2. Propose before/after metrics:
   - runtime
   - shuffle read/write
   - rerun count
   - output partitions
3. Read `broken/04_kafka_retention_too_long.md`.
4. Estimate Kafka storage drivers:
   - event volume
   - average event size
   - replication factor
   - retention days
5. Compare trade-offs in `solutions/03_spark_rerun_strategy.md` and `solutions/04_kafka_retention_policy.md`.

## Expected Learning

Spark cost often comes from recomputation/shuffle. Kafka cost often comes from throughput, retention, replication, and partition count.

## Interview Question

How do you debug a Kafka topic whose storage cost grows faster than expected?

