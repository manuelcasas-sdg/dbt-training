# Jinja Macros & Maintainability Guide

This guide outlines standards for writing maintainable Jinja macros, controlling whitespace, and utilizing existing packages (`dbt_utils`, `codegen`) in this repository.

---

## When to Create a Macro

Create a custom macro in `macros/` when:
1. **DRY (Don't Repeat Yourself)**: A calculation, string manipulation, or conditional case statement is used in more than one model.
2. **Standardization**: Enforcing team-wide logic (e.g., fiscal year calculations, cents-to-dollars conversion, currency conversion).
3. **Cross-Platform Compatibility**: Encapsulating warehouse-specific functions to make SQL portable.

**When NOT to create a macro**:
- Do not wrap single-use standard SQL functions (e.g. wrapping `upper(col)` in a custom macro adds needless indirection).
- Do not build complex business joins inside macros; model dependencies should remain visible in SQL files via `{{ ref(...) }}`.

---

## Macro Design Patterns

### 1. Whitespace Control
Always use hyphenated Jinja tags (`{%-` and `-%}`) on control flow lines to prevent unsightly whitespace and blank lines in compiled SQL.

```sql
{% macro cents_to_dollars(column_name, decimal_places=2) -%}
    round(
        cast(({{ column_name }} / 100.0) as numeric(16, {{ decimal_places }})),
        {{ decimal_places }}
    )
{%- endmacro %}
```

### 2. Return Composable SQL Expressions
Design transformation macros to return valid SQL expressions that fit seamlessly into a `select` list or `where` clause:

```sql
{#- Good: Composable SQL expression -#}
{% macro is_weekend(date_column) -%}
    dayname({{ date_column }}) in ('Sat', 'Sun')
{%- endmacro %}

-- Usage in a model:
select
    order_id,
    order_date,
    {{ is_weekend('order_date') }} as is_order_placed_on_weekend
from orders
```

### 3. Argument Defaults & Type Handling
Always provide sensible default arguments to keep calls concise:

```sql
{% macro truncate_date(date_column, date_part='day') -%}
    date_trunc('{{ date_part }}', {{ date_column }}::timestamp)
{%- endmacro %}
```

---

## Utilizing Installed Packages

This project has `dbt_utils` and `codegen` configured in `packages.yml`. Prefer using these battle-tested packages before writing custom macros from scratch.

### 1. Surrogate Keys (`dbt_utils.generate_surrogate_key`)
Never concatenate strings manually with `md5(col1 || col2)` as nulls can cause collisions. Use `generate_surrogate_key`:

```sql
select
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} as customer_order_key,
    customer_id,
    order_date
from orders
```

### 2. Star Macro (`dbt_utils.star`)
When passing through all columns from an upstream model while modifying only a few:

```sql
select
    {{ dbt_utils.star(from=ref('stg_tpch_sf1__customer'), except=['c_comment']) }},
    coalesce(c_comment, 'no comment') as customer_comment
from {{ ref('stg_tpch_sf1__customer') }}
```

### 3. Automated Scaffolding (`codegen`)
Generate staging models and source YAMLs quickly without manual typing:

```powershell
# Generate source YAML definition
dbt run-operation generate_source --args '{"schema_name": "tpch_sf1", "database_name": "snowflake_sample_data"}'

# Generate base model SQL with all column names and initial aliases
dbt run-operation generate_base_model --args '{"source_name": "tpch_sf1", "table_name": "orders"}'

# Generate documentation and test schema for an existing model
dbt run-operation generate_model_yaml --args '{"model_names": ["stg_tpch_sf1__orders"]}'
```

---

## Testing & Verifying Macros

Test new or updated macros using `dbt compile --inline` or `dbt run-operation`:

```powershell
# Test macro compilation with inline Jinja
dbt compile --inline "{{ cents_to_dollars('price_cents') }}"

# Test macro execution directly against the warehouse
dbt run-operation cents_to_dollars --args '{"column_name": "raw_amount"}'
```
