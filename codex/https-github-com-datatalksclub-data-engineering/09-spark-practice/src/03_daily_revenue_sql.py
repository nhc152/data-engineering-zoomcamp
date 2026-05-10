from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
MARTS = ROOT / "data" / "output" / "marts"


def main() -> None:
    spark = build_spark("daily-revenue-sql")

    spark.read.parquet(str(PARQUET / "orders")).createOrReplaceTempView("orders")
    spark.read.parquet(str(PARQUET / "payments")).createOrReplaceTempView("payments")

    daily = spark.sql(
        """
        with payments_by_order as (
            select
                order_id,
                sum(case when payment_status = 'captured' then amount else 0 end) as captured_amount
            from payments
            group by order_id
        ),

        fact_orders as (
            select
                orders.order_id,
                orders.customer_id,
                orders.order_date,
                orders.order_status,
                case
                    when orders.order_status in ('cancelled', 'refunded') then 0
                    else coalesce(payments_by_order.captured_amount, 0)
                end as recognized_revenue
            from orders
            left join payments_by_order
                on orders.order_id = payments_by_order.order_id
        )

        select
            order_date,
            count(*) as order_count,
            sum(recognized_revenue) as recognized_revenue
        from fact_orders
        group by order_date
        order by order_date
        """
    )

    daily.show(20, truncate=False)
    daily.write.mode("overwrite").partitionBy("order_date").parquet(str(MARTS / "daily_revenue_sql"))

    spark.stop()


if __name__ == "__main__":
    main()

