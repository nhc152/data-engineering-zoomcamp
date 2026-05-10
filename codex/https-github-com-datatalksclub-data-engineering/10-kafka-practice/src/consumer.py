import json
import signal
import sys
from decimal import Decimal, InvalidOperation
from time import sleep

import psycopg
from confluent_kafka import Consumer, KafkaException, Producer

from config import settings


running = True


def stop(_signum, _frame):
    global running
    running = False


signal.signal(signal.SIGINT, stop)
signal.signal(signal.SIGTERM, stop)


def validate_event(event: dict) -> None:
    required = ["event_id", "event_type", "event_timestamp", "order_id", "customer_id", "amount", "order_status"]
    missing = [field for field in required if field not in event or event[field] in (None, "")]
    if missing:
        raise ValueError(f"missing_required_fields={missing}")

    try:
        Decimal(str(event["amount"]))
    except InvalidOperation as exc:
        raise ValueError(f"invalid_amount={event['amount']}") from exc


def send_to_dlq(dlq_producer: Producer, message, event: dict | None, error: Exception) -> None:
    payload = {
        "error_message": str(error),
        "source_topic": message.topic(),
        "source_partition": message.partition(),
        "source_offset": message.offset(),
        "raw_payload": message.value().decode("utf-8", errors="replace"),
        "event": event,
    }
    key = (event or {}).get("order_id", "unknown")
    dlq_producer.produce(
        settings.dlq_topic,
        key=str(key).encode("utf-8"),
        value=json.dumps(payload).encode("utf-8"),
    )
    dlq_producer.flush()


def write_dlq_record(conn, message, event: dict | None, error: Exception) -> None:
    raw_payload = message.value().decode("utf-8", errors="replace")
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into dlq_events (
                event_id,
                order_id,
                source_topic,
                source_partition,
                source_offset,
                error_message,
                raw_payload
            )
            values (%s, %s, %s, %s, %s, %s, %s::jsonb)
            """,
            (
                (event or {}).get("event_id"),
                (event or {}).get("order_id"),
                message.topic(),
                message.partition(),
                message.offset(),
                str(error),
                json.dumps({"raw": raw_payload, "event": event}),
            ),
        )


def process_message(conn, message) -> str:
    event = json.loads(message.value().decode("utf-8"))
    validate_event(event)

    amount = Decimal(str(event["amount"]))
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into processed_events (
                event_id,
                event_type,
                order_id,
                source_topic,
                source_partition,
                source_offset
            )
            values (%s, %s, %s, %s, %s, %s)
            on conflict (event_id) do nothing
            """,
            (
                event["event_id"],
                event["event_type"],
                event["order_id"],
                message.topic(),
                message.partition(),
                message.offset(),
            ),
        )

        if cur.rowcount == 0:
            return "duplicate_skipped"

        cur.execute(
            """
            insert into orders_sink (
                order_id,
                customer_id,
                order_status,
                amount,
                event_timestamp,
                last_event_id,
                updated_at
            )
            values (%s, %s, %s, %s, %s::timestamptz, %s, now())
            on conflict (order_id) do update set
                customer_id = excluded.customer_id,
                order_status = excluded.order_status,
                amount = excluded.amount,
                event_timestamp = excluded.event_timestamp,
                last_event_id = excluded.last_event_id,
                updated_at = now()
            """,
            (
                event["order_id"],
                event["customer_id"],
                event["order_status"],
                amount,
                event["event_timestamp"],
                event["event_id"],
            ),
        )

    return "processed"


def main() -> None:
    consumer = Consumer(
        {
            "bootstrap.servers": settings.kafka_bootstrap_servers,
            "group.id": settings.consumer_group_id,
            "enable.auto.commit": False,
            "auto.offset.reset": "earliest",
        }
    )
    dlq_producer = Producer({"bootstrap.servers": settings.kafka_bootstrap_servers})

    consumer.subscribe([settings.orders_topic])

    print(f"consumer_started group={settings.consumer_group_id} topic={settings.orders_topic}")
    with psycopg.connect(settings.postgres_dsn) as conn:
        while running:
            message = consumer.poll(1.0)
            if message is None:
                continue
            if message.error():
                raise KafkaException(message.error())

            event = None
            last_error = None
            for attempt in range(1, settings.max_retries + 1):
                try:
                    event = json.loads(message.value().decode("utf-8"))
                    result = process_message(conn, message)
                    conn.commit()
                    consumer.commit(message=message, asynchronous=False)
                    print(
                        f"{result} topic={message.topic()} partition={message.partition()} "
                        f"offset={message.offset()} event_id={event.get('event_id')}"
                    )
                    break
                except Exception as exc:
                    conn.rollback()
                    last_error = exc
                    print(
                        f"process_failed attempt={attempt} partition={message.partition()} "
                        f"offset={message.offset()} error={exc}"
                    )
                    sleep(0.5 * attempt)
            else:
                write_dlq_record(conn, message, event, last_error)
                conn.commit()
                send_to_dlq(dlq_producer, message, event, last_error)
                consumer.commit(message=message, asynchronous=False)
                print(
                    f"sent_to_dlq topic={message.topic()} partition={message.partition()} "
                    f"offset={message.offset()} error={last_error}"
                )

    consumer.close()
    print("consumer_stopped")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)

