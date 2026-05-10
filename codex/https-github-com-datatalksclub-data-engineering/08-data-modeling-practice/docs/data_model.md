# Data Model Documentation

## Modeling Goal

Build an ecommerce analytical model that supports:

- daily revenue
- customer lifetime value
- product performance
- customer tier historical reporting
- web event analytics

The model must avoid:

- join explosion
- duplicate revenue
- SCD2 duplicate joins
- inconsistent revenue definitions
- timezone-driven metric drift

## Layering

```text
raw
  -> staging
  -> intermediate
  -> marts
```

## Staging Models

### `stg_customers`

Grain: one row per source customer after deduplication.

Purpose:

- clean customer names and emails
- standardize country and tier
- keep current source attributes

Primary key:

- `customer_id`

### `stg_products`

Grain: one row per source product after deduplication.

Purpose:

- clean product attributes
- standardize category
- expose product price and active flag

Primary key:

- `product_id`

### `stg_orders`

Grain: one row per source order after deduplication.

Purpose:

- normalize order status
- cast timestamps
- derive order dates in UTC and local reporting timezone

Primary key:

- `order_id`

### `stg_order_items`

Grain: one row per item line in an order.

Purpose:

- represent product-level sale detail
- calculate item gross amount

Primary key:

- `order_item_id`

### `stg_payments`

Grain: one row per payment transaction.

Purpose:

- represent captured, voided, failed, and refunded payment events

Primary key:

- `payment_id`

### `stg_refunds`

Grain: one row per refund transaction.

Purpose:

- separate refund events from order creation
- support net revenue and LTV

Primary key:

- `refund_id`

### `stg_events`

Grain: one row per event after deduplication.

Purpose:

- model clickstream/product events
- support DAU and funnel metrics

Primary key:

- `event_id`

## Dimension Models

### `dim_customers_current`

Grain: one row per customer, current version only.

Use when:

- dashboard needs current customer attributes
- historical accuracy of attributes is not required

Do not use when:

- reporting must reflect customer tier at the time of order

### `dim_customers_scd2`

Grain: one row per customer version.

Fields:

- `customer_sk`
- `customer_id`
- `customer_tier`
- `valid_from`
- `valid_to`
- `is_current`

Use when:

- customer tier, region, or account status changes must be historically accurate

Join rule:

```sql
orders.customer_id = customers.customer_id
and orders.order_timestamp >= customers.valid_from
and orders.order_timestamp < coalesce(customers.valid_to, timestamp '9999-12-31')
```

### `dim_products`

Grain: one row per product.

Use when:

- analyzing product/category performance

## Fact Models

### `fct_orders`

Grain: one row per order.

Measures:

- `gross_item_amount`
- `captured_amount`
- `refunded_amount`
- `recognized_revenue`
- `net_revenue`

Important:

- order items must be aggregated to order grain before joining
- payments must be aggregated to order grain before joining

### `fct_order_items`

Grain: one row per order item.

Measures:

- `quantity`
- `unit_price`
- `gross_item_amount`

Use for:

- product revenue
- category revenue
- units sold

Do not use order-level payment amount directly at this grain unless allocation logic is defined.

### `fct_payments`

Grain: one row per payment transaction.

Use for:

- payment success rate
- payment method analysis
- settlement/reconciliation

### `fct_events`

Grain: one row per deduplicated event.

Use for:

- DAU
- funnel conversion
- session analytics

Important:

- event date must specify timezone
- duplicate event IDs must be removed

## Mart Models

### `mart_daily_revenue`

Grain: one row per reporting date.

Source:

- `fct_orders`

Metrics:

- order count
- gross item amount
- recognized revenue
- net revenue

### `mart_customer_ltv`

Grain: one row per customer.

Source:

- `fct_orders`
- `dim_customers_current`

Metrics:

- lifetime order count
- lifetime gross amount
- lifetime net revenue
- first order date
- latest order date

### `mart_product_performance`

Grain: one row per product.

Source:

- `fct_order_items`
- `dim_products`

Metrics:

- units sold
- gross item amount
- order count

## Star Schema

Recommended analytics model:

```text
dim_customers_current
        |
        v
     fct_orders  ---> dim_date
        ^
        |
dim_products <- fct_order_items
```

For product analysis, use `fct_order_items`. For order-level revenue, use `fct_orders`.

## Snowflake Schema Trade-Off

Snowflake example:

```text
fct_order_items -> dim_products -> dim_categories
```

Benefits:

- less duplicated category metadata
- category attributes managed separately

Costs:

- more joins
- BI users need more modeling knowledge
- easier to create inconsistent joins

Recommendation:

- Use star schema for core marts.
- Snowflake only when dimensions are large, shared, or governed separately.

