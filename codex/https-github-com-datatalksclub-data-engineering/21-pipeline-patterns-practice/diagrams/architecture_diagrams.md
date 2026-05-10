# Architecture Diagrams

## Batch ELT

```mermaid
flowchart LR
  A["Source DB / API / Files"] --> B["Extract and Load Raw"]
  B --> C["Warehouse Raw Tables"]
  C --> D["dbt / SQL Transform"]
  D --> E["Marts"]
  E --> F["BI / Reporting"]
```

Failure focus:

- Source extraction delay.
- Bad incremental watermark.
- dbt test failure.
- Late arriving data.

## Batch ETL

```mermaid
flowchart LR
  A["Source Files / DB"] --> B["Spark / Python Transform"]
  B --> C["Curated Files or Warehouse Tables"]
  C --> D["Marts / BI"]
```

Failure focus:

- Transform logic hidden outside warehouse.
- Raw not preserved.
- Spark job failure.

## CDC to Warehouse

```mermaid
flowchart LR
  A["OLTP Database"] --> B["CDC Connector"]
  B --> C["Broker / Raw Changelog"]
  C --> D["Current State Tables"]
  D --> E["Warehouse Marts"]
```

Failure focus:

- WAL/binlog retention.
- Deletes ignored.
- Out-of-order updates.
- Schema drift.

## Event Streaming

```mermaid
flowchart LR
  A["Application Producer"] --> B["Event Broker"]
  B --> C["Stream Processor"]
  C --> D["Realtime Sink"]
  B --> E["Raw Event Archive"]
  C --> F["DLQ"]
```

Failure focus:

- Duplicate events.
- Poison pill.
- Consumer lag.
- Idempotent sink.

## Micro-batch

```mermaid
flowchart LR
  A["Events / Files"] --> B["Windowed Batch Job"]
  B --> C["Warehouse Merge"]
  C --> D["Near-Realtime Mart"]
```

Failure focus:

- Window overlap duplicates.
- Late-arriving events.
- Frequent merge cost.

## Medallion

```mermaid
flowchart LR
  A["Raw Sources"] --> B["Bronze"]
  B --> C["Silver"]
  C --> D["Gold"]
  D --> E["BI / ML / Apps"]
```

Failure focus:

- Bad data passing quality gate.
- Layer ownership unclear.
- Gold table wrong but raw replay possible.

## Lambda

```mermaid
flowchart LR
  A["Event Stream"] --> B["Streaming Path"]
  A --> C["Raw Archive"]
  C --> D["Batch Path"]
  B --> E["Serving Layer"]
  D --> E
```

Failure focus:

- Batch and streaming logic drift.
- Serving layer reconciliation.

## Kappa

```mermaid
flowchart LR
  A["Event Log"] --> B["Stream Processor"]
  B --> C["Serving Tables"]
  A --> D["Replay From Log"]
  D --> B
```

Failure focus:

- Replay cost.
- Log retention.
- Stream logic correctness.

## Outbox

```mermaid
flowchart LR
  A["Application Transaction"] --> B["Business Table"]
  A --> C["Outbox Table"]
  C --> D["Relay"]
  D --> E["Broker Topic"]
  E --> F["Consumers"]
```

Failure focus:

- Relay lag.
- Duplicate publish.
- Consumer idempotency.

## DLQ / Quarantine

```mermaid
flowchart LR
  A["Input Records"] --> B["Validator / Consumer"]
  B --> C["Good Sink"]
  B --> D["DLQ / Quarantine"]
  D --> E["Inspect / Fix / Replay"]
```

Failure focus:

- DLQ not monitored.
- No replay owner.
- Bad records silently accumulate.

## Fan-out

```mermaid
flowchart LR
  A["Shared Source / Topic"] --> B["Fraud Consumer"]
  A --> C["Analytics Consumer"]
  A --> D["ML Feature Consumer"]
```

Failure focus:

- Schema change breaks many consumers.
- Ownership unclear.

## Fan-in

```mermaid
flowchart LR
  A["CRM Customers"] --> D["Canonical Customer Model"]
  B["App Users"] --> D
  C["Support Contacts"] --> D
  D --> E["Customer 360"]
```

Failure focus:

- Identity resolution.
- Source precedence.
- Semantic mismatch.

