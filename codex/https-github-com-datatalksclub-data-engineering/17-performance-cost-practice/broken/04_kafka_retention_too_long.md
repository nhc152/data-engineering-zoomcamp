# Broken Scenario 04 - Kafka Retention Too Long

## Symptom

Kafka storage cost keeps growing. Topics retain high-volume events far longer than required.

## Root Cause

Retention policy was set broadly without owner approval or data replay requirement.

## Evidence To Collect

- topic retention.ms / retention.bytes
- topic throughput
- replication factor
- average message size
- replay requirement
- topic owner

## Expected Fix

Set retention based on business/replay needs:

- short retention for high-volume transient topics
- longer retention for audit/replay topics
- compacted topics for latest-state use cases

## Trade-off

Short retention lowers cost but reduces replay window.

