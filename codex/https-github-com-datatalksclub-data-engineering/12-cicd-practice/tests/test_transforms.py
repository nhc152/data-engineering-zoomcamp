from __future__ import annotations

import pytest

from src.transforms import (
    normalize_status,
    parse_utc_timestamp,
    recognized_revenue,
    validate_required_fields,
)


def test_normalize_status() -> None:
    assert normalize_status(" PAID ") == "paid"
    assert normalize_status("Completed") == "completed"
    assert normalize_status("canceled") == "cancelled"
    assert normalize_status("unexpected") == "unknown"
    assert normalize_status(None) == "unknown"


def test_recognized_revenue() -> None:
    assert recognized_revenue("paid", 100.0) == 100.0
    assert recognized_revenue("completed", 50) == 50.0
    assert recognized_revenue("cancelled", 100.0) == 0.0
    assert recognized_revenue("refunded", 100.0) == 0.0
    assert recognized_revenue("bad_status", 100.0) == 0.0


def test_parse_utc_timestamp() -> None:
    parsed = parse_utc_timestamp("2026-05-01T10:00:00Z")
    assert parsed.isoformat() == "2026-05-01T10:00:00+00:00"


def test_parse_utc_timestamp_requires_timezone() -> None:
    with pytest.raises(ValueError):
        parse_utc_timestamp("2026-05-01T10:00:00")


def test_validate_required_fields() -> None:
    record = {"order_id": "O1", "customer_id": "", "amount": None}
    assert validate_required_fields(record, ["order_id", "customer_id", "amount"]) == ["customer_id", "amount"]

