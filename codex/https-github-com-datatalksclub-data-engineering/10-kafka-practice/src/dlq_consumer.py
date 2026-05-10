import json

from confluent_kafka import Consumer, KafkaException

from config import settings


def main() -> None:
    consumer = Consumer(
        {
            "bootstrap.servers": settings.kafka_bootstrap_servers,
            "group.id": "orders-dlq-reader",
            "enable.auto.commit": False,
            "auto.offset.reset": "earliest",
        }
    )
    consumer.subscribe([settings.dlq_topic])

    print(f"reading_dlq topic={settings.dlq_topic}")
    try:
        while True:
            message = consumer.poll(1.0)
            if message is None:
                continue
            if message.error():
                raise KafkaException(message.error())

            payload = json.loads(message.value().decode("utf-8"))
            print(json.dumps(payload, indent=2))
            consumer.commit(message=message, asynchronous=False)
    except KeyboardInterrupt:
        pass
    finally:
        consumer.close()


if __name__ == "__main__":
    main()

