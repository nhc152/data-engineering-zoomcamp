from __future__ import annotations

from datetime import UTC, datetime
from decimal import Decimal, InvalidOperation
from typing import Any


def normalize_status(status: Any) -> str:
    if status is None:
        return "unknown"
    normalized = str(status).strip().lower()
    if normalized in {"paid", "completed", "shipped"}:
        return normalized
    if normalized in {"cancelled", "canceled"}:
        return "cancelled"
    if normalized == "refunded":
        return "refunded"
    return "unknown"


def parse_timestamp(value: Any) -> datetime:
    if value is None or str(value).strip() == "":
        raise ValueError("missing timestamp")
    text = str(value).strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    parsed = datetime.fromisoformat(text)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=UTC)
    return parsed.astimezone(UTC)


def parse_amount(value: Any) -> Decimal:
    try:
        amount = Decimal(str(value).strip())
    except (InvalidOperation, AttributeError) as exc:
        raise ValueError(f"invalid amount: {value}") from exc
    if amount < 0:
        raise ValueError(f"negative amount: {value}")
    return amount.quantize(Decimal("0.01"))


def normalize_order(record: dict[str, Any]) -> dict[str, Any]:
    order_timestamp = parse_timestamp(record.get("order_timestamp"))
    updated_at = parse_timestamp(record.get("updated_at", record.get("order_timestamp")))

    return {
        "order_id": str(record.get("order_id", "")).strip(),
        "customer_id": str(record.get("customer_id", "")).strip(),
        "order_timestamp": order_timestamp,
        "order_date": order_timestamp.date(),
        "status": normalize_status(record.get("status")),
        "amount": parse_amount(record.get("amount")),
        "updated_at": updated_at,
    }


def deduplicate_latest(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    winners: dict[str, dict[str, Any]] = {}
    for record in records:
        order_id = record["order_id"]
        current = winners.get(order_id)
        if current is None or record["updated_at"] > current["updated_at"]:
            winners[order_id] = record
    return list(winners.values())

