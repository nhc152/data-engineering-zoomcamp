import pytest

from src.validate import validate_order, validate_required_columns


def test_validate_required_columns_fails_when_customer_id_missing() -> None:
    records = [
        {
            "order_id": "O1",
            "order_timestamp": "2026-05-09T00:00:00Z",
            "status": "paid",
            "amount": "10.00",
        }
    ]

    with pytest.raises(ValueError, match="Missing required columns"):
        validate_required_columns(records)


def test_validate_order_rejects_missing_business_key() -> None:
    is_valid, reason = validate_order(
        {
            "order_id": "",
            "customer_id": "C1",
            "status": "paid",
            "amount": "10.00",
        }
    )

    assert is_valid is False
    assert reason == "missing_order_id"


def test_validate_order_accepts_valid_order() -> None:
    is_valid, reason = validate_order(
        {
            "order_id": "O1",
            "customer_id": "C1",
            "status": "paid",
            "amount": "10.00",
        }
    )

    assert is_valid is True
    assert reason is None

