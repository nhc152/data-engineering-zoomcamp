from common import explain


def main() -> None:
    print("Scenario: exactly-once claim has a boundary.")
    print()
    print("Kafka transaction can make consume-process-produce atomic inside Kafka.")
    print("But if the consumer writes to an external database, the database write and Kafka offset commit are separate unless you design a transaction/outbox/idempotent sink.")

    print(
        """
Failure timeline:
1. Consumer reads event offset 10.
2. Consumer writes row to warehouse.
3. Warehouse commit succeeds.
4. Consumer crashes before Kafka offset commit.
5. Consumer restarts and reads offset 10 again.
6. Without idempotent sink, duplicate row is written.
"""
    )

    explain(
        "Correct mental model",
        [
            "Exactly-once is not a blanket guarantee across all systems.",
            "Kafka exactly-once semantics mainly help within Kafka transactional boundaries.",
            "External sinks still require idempotency, dedup keys, transactions, or outbox patterns.",
            "For Data Engineering, design for at-least-once processing plus idempotent outputs.",
        ],
    )

    explain(
        "Connections",
        [
            "Kafka: offset commit and external sink write boundary.",
            "CDC: source log position and warehouse merge boundary.",
            "Spark: task retry and output commit boundary.",
            "Airflow/Kestra: task retry and side-effect boundary.",
        ],
    )


if __name__ == "__main__":
    main()

