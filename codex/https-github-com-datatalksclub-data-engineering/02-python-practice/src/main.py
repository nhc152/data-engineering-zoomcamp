from __future__ import annotations

import argparse
import logging
import uuid
from pathlib import Path

from src.config import load_config
from src.extract import (
    fetch_simulated_api_pages,
    read_csv_records,
    read_json_records,
    read_jsonl_records,
    write_raw_copy,
)
from src.load import (
    connect,
    finish_pipeline_run,
    load_rejected_records,
    start_pipeline_run,
    upsert_orders,
)
from src.logging_config import configure_logging
from src.transform import deduplicate_latest, normalize_order
from src.validate import split_valid_rejected, validate_required_columns


logger = logging.getLogger(__name__)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Python ingestion practice pipeline")
    parser.add_argument("--source", choices=["csv", "json", "jsonl", "api"], required=True)
    parser.add_argument("--input-path", type=Path)
    parser.add_argument("--api-pages-dir", type=Path)
    parser.add_argument("--run-date", required=True)
    parser.add_argument("--run-id", default=None)
    parser.add_argument("--env-file", default=".env")
    parser.add_argument("--log-level", default="INFO")
    return parser.parse_args()


def extract_records(args: argparse.Namespace, config) -> list[dict]:
    if args.source == "csv":
        if not args.input_path:
            raise ValueError("--input-path is required for csv source")
        return read_csv_records(args.input_path)
    if args.source == "json":
        if not args.input_path:
            raise ValueError("--input-path is required for json source")
        return read_json_records(args.input_path)
    if args.source == "jsonl":
        if not args.input_path:
            raise ValueError("--input-path is required for jsonl source")
        return read_jsonl_records(args.input_path)
    if args.source == "api":
        if not args.api_pages_dir:
            raise ValueError("--api-pages-dir is required for api source")
        return fetch_simulated_api_pages(
            args.api_pages_dir,
            max_attempts=config.max_retries,
            base_seconds=config.retry_base_seconds,
            max_seconds=config.retry_max_seconds,
        )
    raise ValueError(f"Unsupported source: {args.source}")


def main() -> None:
    args = parse_args()
    configure_logging(args.log_level)
    config = load_config(args.env_file)
    run_id = args.run_id or f"run_{args.run_date}_{uuid.uuid4().hex[:8]}"

    logger.info(
        "pipeline_started",
        extra={"run_id": run_id, "source": args.source, "run_date": args.run_date},
    )

    conn = connect(config.postgres_dsn)
    start_pipeline_run(conn, run_id=run_id, source_name=args.source, run_date=args.run_date)

    extracted_count = valid_count = rejected_count = loaded_count = 0
    try:
        raw_records = extract_records(args, config)
        extracted_count = len(raw_records)
        validate_required_columns(raw_records)

        raw_output_path = config.data_dir / "raw" / run_id / f"{args.source}_orders.jsonl"
        write_raw_copy(raw_records, raw_output_path)

        normalizable_raw_records = []
        normalized_records = []
        transform_rejections = []
        for record in raw_records:
            try:
                normalized_records.append(normalize_order(record))
                normalizable_raw_records.append(record)
            except ValueError as exc:
                transform_rejections.append((record, str(exc)))

        valid_records, validation_rejections = split_valid_rejected(
            normalizable_raw_records,
            normalized_records,
        )
        all_rejections = transform_rejections + validation_rejections

        deduped_records = deduplicate_latest(valid_records)
        valid_count = len(deduped_records)
        rejected_count = len(all_rejections)

        load_rejected_records(
            conn,
            run_id=run_id,
            source_name=args.source,
            rejected_records=all_rejections,
        )
        loaded_count = upsert_orders(
            conn,
            deduped_records,
            source_name=args.source,
            run_id=run_id,
        )
        finish_pipeline_run(
            conn,
            run_id=run_id,
            status="success",
            extracted_count=extracted_count,
            valid_count=valid_count,
            rejected_count=rejected_count,
            loaded_count=loaded_count,
        )
        logger.info(
            "pipeline_finished",
            extra={
                "run_id": run_id,
                "extracted_count": extracted_count,
                "valid_count": valid_count,
                "rejected_count": rejected_count,
                "loaded_count": loaded_count,
            },
        )
    except Exception as exc:
        finish_pipeline_run(
            conn,
            run_id=run_id,
            status="failed",
            extracted_count=extracted_count,
            valid_count=valid_count,
            rejected_count=rejected_count,
            loaded_count=loaded_count,
            error_message=str(exc),
        )
        logger.exception("pipeline_failed", extra={"run_id": run_id})
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
