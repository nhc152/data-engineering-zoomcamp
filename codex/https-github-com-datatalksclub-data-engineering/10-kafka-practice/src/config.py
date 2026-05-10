import os
from dataclasses import dataclass

from dotenv import load_dotenv


load_dotenv()


@dataclass(frozen=True)
class Settings:
    kafka_bootstrap_servers: str = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9094")
    orders_topic: str = os.getenv("ORDERS_TOPIC", "ecommerce.orders")
    dlq_topic: str = os.getenv("DLQ_TOPIC", "ecommerce.orders.dlq")
    consumer_group_id: str = os.getenv("CONSUMER_GROUP_ID", "orders-postgres-sink")
    postgres_host: str = os.getenv("POSTGRES_HOST", "localhost")
    postgres_port: int = int(os.getenv("POSTGRES_PORT", "5432"))
    postgres_db: str = os.getenv("POSTGRES_DB", "kafka_lab")
    postgres_user: str = os.getenv("POSTGRES_USER", "kafka_user")
    postgres_password: str = os.getenv("POSTGRES_PASSWORD", "kafka_password")
    max_retries: int = int(os.getenv("MAX_RETRIES", "3"))

    @property
    def postgres_dsn(self) -> str:
        return (
            f"host={self.postgres_host} "
            f"port={self.postgres_port} "
            f"dbname={self.postgres_db} "
            f"user={self.postgres_user} "
            f"password={self.postgres_password}"
        )


settings = Settings()

