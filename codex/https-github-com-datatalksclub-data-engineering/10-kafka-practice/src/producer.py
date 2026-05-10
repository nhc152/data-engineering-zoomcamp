import argparse
import json
from pathlib import Path

from confluent_kafka import Producer

from config import settings


def delivery_report(error, message):
    if error is not None:
        print(f"delivery_failed topic={message.topic()} error={error}")
        return
    print(
        "delivered "
        f"topic={message.topic()} partition={message.partition()} "
        f"offset={message.offset()} key={message.key().decode('utf-8')}"
    )


def produce_file(path: Path) -> None:
    producer = Producer(
        {
            "bootstrap.servers": settings.kafka_bootstrap_servers,
            "enable.idempotence": True,
            "acks": "all",
            "retries": 5,
            "linger.ms": 20,
            "compression.type": "snappy",
        }
    )

    with path.open("r", encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            event = json.loads(line)
            key = event["order_id"]
            value = json.dumps(event).encode("utf-8")
            producer.produce(
                settings.orders_topic,
                key=key.encode("utf-8"),
                value=value,
                callback=delivery_report,
            )
            producer.poll(0)

    producer.flush()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", required=True, help="Path to JSONL event file")
    args = parser.parse_args()
    produce_file(Path(args.file))


if __name__ == "__main__":
    main()

