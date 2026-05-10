from __future__ import annotations

from datetime import datetime, timezone


VALID_ORDER_STATUSES = {"paid", "completed", "shipped", "cancelled", "refunded"}


def normalize_status(value: str | None) -> str:
    if value is None:
        return "unknown"
    normalized = value.strip().lower()
    if normalized in {"canceled"}:
        return "cancelled"
    if normalized in VALID_ORDER_STATUSES:
        return normalized
    return "unknown"


def recognized_revenue(order_status: str, captured_amount: float | int | None) -> float:
    normalized_status = normalize_status(order_status)
    if normalized_status in {"cancelled", "refunded", "unknown"}:
        return 0.0
    return float(captured_amount or 0.0)


def parse_utc_timestamp(value: str) -> datetime:
    if not value:
        raise ValueError("timestamp value is required")
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        raise ValueError("timestamp must include timezone")
    return parsed.astimezone(timezone.utc)


def validate_required_fields(record: dict[str, object], required_fields: list[str]) -> list[str]:
    missing = []
    for field in required_fields:
        if field not in record or record[field] in (None, ""):
            missing.append(field)
    return missing

