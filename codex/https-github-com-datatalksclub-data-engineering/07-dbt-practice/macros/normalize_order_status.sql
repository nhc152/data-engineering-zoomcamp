{% macro normalize_order_status(column_name) -%}
case
    when lower(trim({{ column_name }})) in ('paid', 'shipped', 'completed') then lower(trim({{ column_name }}))
    when lower(trim({{ column_name }})) in ('cancelled', 'canceled') then 'cancelled'
    when lower(trim({{ column_name }})) = 'refunded' then 'refunded'
    else 'unknown'
end
{%- endmacro %}

