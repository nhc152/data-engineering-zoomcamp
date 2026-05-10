import csv
from decimal import Decimal
import logging
from pathlib import Path

from de_pipeline.config import load_settings
from de_pipeline.db import connect


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)


def read_orders(path: Path) -> list[dict[str, object]]:
    if not path.exists():
        raise FileNotFoundError(f"Input file does not exist: {path}")

    orders: list[dict[str, object]] = []
    with path.open("r", encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)
        required_columns = {
            "order_id",
            "customer_id",
            "order_status",
            "order_amount",
            "order_date",
        }
        missing_columns = required_columns - set(reader.fieldnames or [])
        if missing_columns:
            raise RuntimeError(f"Missing required columns: {sorted(missing_columns)}")

        for row in reader:
            orders.append(
                {
                    "order_id": row["order_id"].strip(),
                    "customer_id": row["customer_id"].strip(),
                    "order_status": row["order_status"].strip().lower(),
                    "order_amount": Decimal(row["order_amount"]),
                    "order_date": row["order_date"],
                }
            )
    return orders


def upsert_orders(settings, orders: list[dict[str, object]]) -> int:
    sql = """
        insert into raw.orders (
            order_id,
            customer_id,
            order_status,
            order_amount,
            order_date
        )
        values (
            %(order_id)s,
            %(customer_id)s,
            %(order_status)s,
            %(order_amount)s,
            %(order_date)s
        )
        on conflict (order_id) do update set
            customer_id = excluded.customer_id,
            order_status = excluded.order_status,
            order_amount = excluded.order_amount,
            order_date = excluded.order_date,
            loaded_at = now();
    """
    with connect(settings) as connection:
        with connection.cursor() as cursor:
            cursor.executemany(sql, orders)
        connection.commit()
    return len(orders)


def main() -> None:
    settings = load_settings()
    logger.info("Starting Docker practice pipeline")
    logger.info("Database host: %s", settings.database_host)
    logger.info("Input file: %s", settings.input_file)

    orders = read_orders(Path(settings.input_file))
    loaded_count = upsert_orders(settings, orders)

    logger.info("Loaded orders: %s", loaded_count)
    logger.info("Pipeline completed successfully")


if __name__ == "__main__":
    main()

