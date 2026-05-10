from __future__ import annotations

from typing import Any


REQUIRED_RAW_COLUMNS = {
    "order_id",
    "customer_id",
    "order_timestamp",
    "status",
    "amount",
}


def validate_required_columns(records: list[dict[str, Any]]) -> None:
    if not records:
        raise ValueError("No records found")

    observed = set().union(*(record.keys() for record in records))
    missing = REQUIRED_RAW_COLUMNS - observed
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")


def validate_order(record: dict[str, Any]) -> tuple[bool, str | None]:
    if not record.get("order_id"):
        return False, "missing_order_id"
    if not record.get("customer_id"):
        return False, "missing_customer_id"
    if record.get("status") == "unknown":
        return False, "unknown_status"
    if record.get("amount") is None:
        return False, "missing_amount"
    return True, None


def split_valid_rejected(
    raw_records: list[dict[str, Any]],
    normalized_records: list[dict[str, Any]],
) -> tuple[list[dict[str, Any]], list[tuple[dict[str, Any], str]]]:
    valid: list[dict[str, Any]] = []
    rejected: list[tuple[dict[str, Any], str]] = []

    for raw_record, normalized_record in zip(raw_records, normalized_records, strict=True):
        is_valid, reason = validate_order(normalized_record)
        if is_valid:
            valid.append(normalized_record)
        else:
            rejected.append((raw_record, reason or "unknown_reason"))

    return valid, rejected

