# CTE Patterns & SQL Style Guide (Snowflake)

This reference outlines the required Common Table Expression (CTE) architecture, SQL formatting standards, and Snowflake-specific best practices for this repository.

---

## The 4-Stage CTE Architecture

All non-trivial dbt models must adhere to the 4-stage CTE structure:

```
[Import CTEs] ──► [Logical / Business CTEs] ──► [Final CTE] ──► [select * from final]
```

### Stage 1: Import CTEs
- Every `{{ source(...) }}` or `{{ ref(...) }}` call belongs in an import CTE at the top of the file.
- Perform early column pruning (don't select unused columns), renaming to `snake_case`, and initial casting here.
- Never join in an import CTE.

```sql
with orders as (

    select
        o_orderkey as order_id,
        o_custkey as customer_id,
        o_orderstatus as order_status_code,
        o_totalprice as total_amount,
        o_orderdate as order_date

    from {{ source('tpch_sf1', 'orders') }}

),

customers as (

    select
        c_custkey as customer_id,
        c_name as customer_name,
        c_mktsegment as market_segment

    from {{ ref('stg_tpch_sf1__customer') }}

)
```

### Stage 2: Logical / Transformation CTEs
- Break complex transformations into distinct, named logical steps.
- Each CTE should have a single responsibility (e.g., `orders_filtered`, `customer_order_aggregates`, `joined_orders_customers`).
- Avoid multi-level nesting; refer only to previous CTEs.

```sql
customer_orders_joined as (

    select
        orders.order_id,
        orders.customer_id,
        customers.customer_name,
        customers.market_segment,
        orders.order_status_code,
        orders.total_amount,
        orders.order_date

    from orders
    inner join customers
        on orders.customer_id = customers.customer_id

),

orders_classified as (

    select
        order_id,
        customer_id,
        customer_name,
        market_segment,
        order_status_code,
        total_amount,
        order_date,
        case
            when total_amount >= 100000 then 'high_value'
            when total_amount >= 25000 then 'mid_value'
            else 'standard_value'
        end as order_tier

    from customer_orders_joined

)
```

### Stage 3: Final CTE
- Assembles and reorders the output columns cleanly.
- Applies standard column ordering:
  1. Primary Key (`*_id` or `*_key`)
  2. Foreign Keys
  3. Attributes & Dimensions (categorical, strings)
  4. Dates, Times & Timestamps
  5. Metrics & Financials (integers, floats, aggregates)

```sql
final as (

    select
        -- Primary Key
        order_id,

        -- Foreign Keys
        customer_id,

        -- Attributes
        customer_name,
        market_segment,
        order_status_code,
        order_tier,

        -- Dates
        order_date,

        -- Metrics
        total_amount

    from orders_classified

)
```

### Stage 4: Final Select Statement
- The model must always conclude with:
```sql
select * from final
```
- **Why?** This allows developers and reviewers to quickly debug any stage in the model by temporarily changing `final` to any upstream CTE (e.g. `select * from customer_orders_joined`).

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Is Prohibited | Recommended Alternative |
| :--- | :--- | :--- |
| **Nested Subqueries** (`select ... from (select ... from ...)`) | Hard to read, diff, and maintain. | Move each subquery to a dedicated, named CTE. |
| **`select *` in Transformation CTEs** | Obscures column lineage and can break downstream models if schemas change. | Explicitly list required columns. |
| **Mixing Joins and Final Output** | Obscures transformations and makes debugging difficult. | Join in a logical CTE, then project in `final`. |
| **Non-descriptive CTE Names** (`temp`, `data`, `t1`, `cte_1`) | Harms code maintainability and context. | Use descriptive, purpose-driven names (`aggregated_items`, `valid_orders`). |

---

## Snowflake SQL Conventions

### 1. Casing & Identifiers
- Keep all SQL keywords lowercase: `select`, `from`, `where`, `inner join`, `group by`, `order by`.
- Column aliases must be lower `snake_case`. Snowflake columns are naturally uppercase in catalog metadata, but dbt models should output normalized lowercase aliases for cross-tool consistency.

### 2. Type Casting
- Use explicit casts: `col::bigint` or `cast(col as bigint)`.
- Use `try_cast(col as <type>)` when casting incoming untrusted source string values to prevent query failures.

### 3. Null Handling & Functions
- Use `coalesce(column, fallback_value)` to guarantee non-null values for dimension joins.
- Use `nullif(column, '')` to normalize empty strings into SQL `null`.

### 4. Deduplication
- For deduplication in Snowflake, you can leverage `qualify` in a dedicated logical CTE:
```sql
deduped as (

    select
        order_id,
        updated_at,
        order_status

    from orders_raw
    qualify row_number() over (
        partition by order_id
        order by updated_at desc
    ) = 1

)
```
