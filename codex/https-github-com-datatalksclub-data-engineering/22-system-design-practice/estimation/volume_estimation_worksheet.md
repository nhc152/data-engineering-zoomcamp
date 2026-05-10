# Volume Estimation Worksheet

Use this worksheet for every scenario.

## Inputs

```text
daily_active_users =
events_per_user_per_day =
transactions_per_day =
average_event_size_kb =
peak_multiplier =
retention_days =
compression_ratio =
```

## Event Volume

```text
events_per_day = daily_active_users * events_per_user_per_day
events_per_second_avg = events_per_day / 86400
events_per_second_peak = events_per_second_avg * peak_multiplier
```

## Storage

```text
raw_gb_per_day = events_per_day * average_event_size_kb / 1024 / 1024
compressed_gb_per_day = raw_gb_per_day / compression_ratio
retention_storage_gb = compressed_gb_per_day * retention_days
```

## Warehouse Query Cost Thinking

Estimate:

```text
fact_table_gb_per_day =
query_days_scanned =
columns_scanned_ratio =
estimated_gb_scanned = fact_table_gb_per_day * query_days_scanned * columns_scanned_ratio
```

## Streaming Partition Estimate

Rough thinking:

```text
peak_events_per_second =
target_events_per_second_per_partition =
partitions_needed = peak_events_per_second / target_events_per_second_per_partition
```

Then discuss:

- ordering key
- hot key risk
- future growth
- consumer parallelism

## Backfill Estimate

```text
days_to_backfill =
gb_per_day =
total_gb_to_process =
cluster_or_warehouse_capacity =
estimated_runtime =
```

## Interview Note

The exact number is less important than showing that architecture changes with scale.

Bad:

```text
Kafka can scale.
```

Better:

```text
At peak 20k events/sec, I would start with partitioning by customer_id or account_id, but I would watch for hot keys. I would size partitions for consumer parallelism and future growth, not only current throughput.
```

