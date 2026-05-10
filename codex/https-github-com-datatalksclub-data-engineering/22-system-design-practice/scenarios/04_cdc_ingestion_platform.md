# Scenario 04 - CDC Ingestion Platform

## Prompt

Design a CDC ingestion platform that replicates multiple OLTP databases into a warehouse. It must support inserts, updates, deletes, schema evolution, and current-state tables.

## Requirements To Clarify

- Which databases?
- Number of tables?
- Write throughput?
- Is near-real-time required?
- Are deletes required?
- How long is source log retention?
- How will schema changes be managed?
- Do we need raw changelog retention?

## Suggested Assumptions

- 20 source databases.
- 300 tables.
- 50k row changes/sec peak across all sources.
- 5 minute warehouse freshness target.
- Deletes required.
- Raw changelog retained for 90 days.

## Deliverables

Design:

- connector layer
- raw changelog
- current-state builder
- schema evolution process
- delete handling
- resnapshot strategy
- lag monitoring

