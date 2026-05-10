# ERD and Architecture

## Core Star Schema

```mermaid
erDiagram
    DIM_CUSTOMERS_CURRENT ||--o{ FCT_ORDERS : places
    DIM_PRODUCTS ||--o{ FCT_ORDER_ITEMS : describes
    FCT_ORDERS ||--o{ FCT_ORDER_ITEMS : contains
    FCT_ORDERS ||--o{ FCT_PAYMENTS : paid_by

    DIM_CUSTOMERS_CURRENT {
        string customer_id PK
        string customer_name
        string customer_tier
        string country
    }

    DIM_PRODUCTS {
        string product_id PK
        string product_name
        string category
        numeric current_unit_price
    }

    FCT_ORDERS {
        string order_id PK
        string customer_id FK
        date order_date
        timestamp order_timestamp
        string order_status
        numeric gross_item_amount
        numeric captured_amount
        numeric refunded_amount
        numeric recognized_revenue
        numeric net_revenue
    }

    FCT_ORDER_ITEMS {
        string order_item_id PK
        string order_id FK
        string product_id FK
        int quantity
        numeric unit_price
        numeric gross_item_amount
    }

    FCT_PAYMENTS {
        string payment_id PK
        string order_id FK
        string payment_status
        numeric amount
        timestamp payment_timestamp
    }
```

## SCD2 Customer Dimension

```mermaid
erDiagram
    DIM_CUSTOMERS_SCD2 ||--o{ FCT_ORDERS : historical_customer_context

    DIM_CUSTOMERS_SCD2 {
        string customer_sk PK
        string customer_id
        string customer_tier
        timestamp valid_from
        timestamp valid_to
        boolean is_current
    }

    FCT_ORDERS {
        string order_id PK
        string customer_id
        timestamp order_timestamp
    }
```

Join requires:

```text
customer_id + order_timestamp between valid_from and valid_to
```

Joining only by `customer_id` is wrong and can duplicate rows.

## Event Modeling

```mermaid
erDiagram
    FCT_EVENTS }o--|| DIM_CUSTOMERS_CURRENT : belongs_to

    FCT_EVENTS {
        string event_id PK
        string customer_id FK
        string session_id
        string event_name
        timestamp event_timestamp_utc
        date event_date_utc
        date event_date_local
    }
```

## Mart Layer

```text
fct_orders -> mart_daily_revenue
fct_orders + dim_customers_current -> mart_customer_ltv
fct_order_items + dim_products -> mart_product_performance
fct_events -> mart_daily_active_users
```

Each mart has a business-facing grain and metric definition.

