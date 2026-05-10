from decimal import Decimal

import pytest

from src.transform import deduplicate_latest, normalize_order, normalize_status, parse_amount


def test_normalize_status() -> None:
    assert normalize_status(" PAID ") == "paid"
    assert normalize_status("CANCELED") == "cancelled"
    assert normalize_status(None) == "unknown"
    assert normalize_status("unexpected") == "unknown"


def test_parse_amount_rejects_bad_type() -> None:
    with pytest.raises(ValueError, match="invalid amount"):
        parse_amount("not_a_number")


def test_normalize_order_parses_timestamp_and_amount() -> None:
    record = normalize_order(
        {
            "order_id": " O1 ",
            "customer_id": " C1 ",
            "order_timestamp": "2026-05-09T08:00:00+07:00",
            "status": "PAID",
            "amount": "10.50",
            "updated_at": "2026-05-09T08:01:00+07:00",
        }
    )

    assert record["order_id"] == "O1"
    assert record["customer_id"] == "C1"
    assert record["status"] == "paid"
    assert record["amount"] == Decimal("10.50")
    assert str(record["order_date"]) == "2026-05-09"


def test_deduplicate_latest_keeps_latest_updated_at() -> None:
    older = normalize_order(
        {
            "order_id": "O1",
            "customer_id": "C1",
            "order_timestamp": "2026-05-09T00:00:00Z",
            "status": "paid",
            "amount": "10.00",
            "updated_at": "2026-05-09T00:01:00Z",
        }
    )
    newer = normalize_order(
        {
            "order_id": "O1",
            "customer_id": "C1",
            "order_timestamp": "2026-05-09T00:00:00Z",
            "status": "completed",
            "amount": "12.00",
            "updated_at": "2026-05-09T00:05:00Z",
        }
    )

    result = deduplicate_latest([older, newer])

    assert len(result) == 1
    assert result[0]["status"] == "completed"
    assert result[0]["amount"] == Decimal("12.00")

