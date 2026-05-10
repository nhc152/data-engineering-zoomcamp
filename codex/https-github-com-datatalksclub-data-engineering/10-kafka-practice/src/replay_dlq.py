import json

from confluent_kafka import Consumer, KafkaException, Producer

from config import settings


def main() -> None:
    consumer = Consumer(
        {
            "bootstrap.servers": settings.kafka_bootstrap_servers,
            "group.id": "orders-dlq-replay",
            "enable.auto.commit": False,
            "auto.offset.reset": "earliest",
        }
    )
    producer = Producer({"bootstrap.servers": settings.kafka_bootstrap_servers})
    consumer.subscribe([settings.dlq_topic])

    print("replay_started")
    try:
        while True:
            message = consumer.poll(1.0)
            if message is None:
                continue
            if message.error():
                raise KafkaException(message.error())

            dlq_payload = json.loads(message.value().decode("utf-8"))
            event = dlq_payload.get("event")
            if not event:
                print(f"skip_no_event offset={message.offset()}")
                consumer.commit(message=message, asynchronous=False)
                continue

            # Lab-only fix for poison amount. In production, fix source data or code deliberately.
            if event.get("amount") == "not-a-number":
                event["amount"] = 144.00

            producer.produce(
                settings.orders_topic,
                key=event["order_id"].encode("utf-8"),
                value=json.dumps(event).encode("utf-8"),
            )
            producer.flush()
            consumer.commit(message=message, asynchronous=False)
            print(f"replayed event_id={event.get('event_id')} order_id={event.get('order_id')}")
    except KeyboardInterrupt:
        pass
    finally:
        consumer.close()


if __name__ == "__main__":
    main()

