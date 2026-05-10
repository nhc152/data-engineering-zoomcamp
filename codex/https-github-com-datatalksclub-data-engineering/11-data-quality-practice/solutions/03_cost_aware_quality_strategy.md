# Solution - Cost-Aware Quality Strategy

## Problem

Quality checks can become expensive if they scan full fact tables repeatedly.

## Strategy

### Run Frequently

Cheap checks:

- latest partition freshness
- expected file arrived
- current day row count
- required fields on recent partition

### Run Daily

Medium checks:

- revenue reconciliation by date
- duplicate keys for recent partitions
- accepted values

### Run Weekly or After Backfill

Expensive checks:

- full-table uniqueness
- historical reconciliation
- distribution drift over long windows

## Rule

Quality checks should protect business trust without becoming a hidden cost center.

