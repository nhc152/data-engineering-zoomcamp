"""
Broken consumer pattern.

This commits Kafka offset before writing to PostgreSQL.
If the process crashes after commit and before sink write, the event is lost
for this consumer group.

Do not use this pattern for data pipelines.
"""

import json
import sys
from pathlib import Path

from confluent_kafka import Consumer, KafkaException

sys.path.append(str(Path(__file__).resolve().parents[1] / "src"))
from config import settings  # noqa: E402


consumer = Consumer(
    {
        "bootstrap.servers": settings.kafka_bootstrap_servers,
        "group.id": "broken-commit-before-write",
        "enable.auto.commit": False,
        "auto.offset.reset": "earliest",
    }
)
consumer.subscribe([settings.orders_topic])

print("broken_consumer_started")
try:
    while True:
        message = consumer.poll(1.0)
        if message is None:
            continue
        if message.error():
            raise KafkaException(message.error())

        event = json.loads(message.value().decode("utf-8"))
        consumer.commit(message=message, asynchronous=False)
        print(f"committed_before_write event_id={event.get('event_id')}")
        raise RuntimeError("simulated crash after offset commit and before sink write")
except KeyboardInterrupt:
    pass
finally:
    consumer.close()
