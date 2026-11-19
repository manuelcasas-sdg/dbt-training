---
name: dbt-sql-standards
description: >-
  SQL syntax standards, CTE structures, Jinja macro patterns, and code maintainability
  guidelines for Snowflake dbt development in this project. Use when writing, refactoring,
  reviewing, or optimizing dbt models, CTEs, macros, or SQL queries.
---

# dbt SQL Standards & Maintainability Guidelines

This skill provides mandatory coding conventions, SQL design patterns, and maintainability rules for dbt development targeting Snowflake in this repository (`training`).

## Quick Navigation
- [CTE Patterns & SQL Syntax Guide](./references/cte_patterns.md): Import/logical/final CTE structure, column ordering, anti-patterns, and Snowflake-specific styling.
- [Jinja Macros & Maintainability Guide](./references/jinja_macros.md): Authoring reusable macros, whitespace control, parameter defaults, and leveraging `dbt_utils` and `codegen`.

---

## Core Rules & Modeling Principles

### 1. Mandatory CTE Architecture
Every SQL model must follow the **Modular CTE Pattern**:
1. **Import CTEs**: 1:1 references to `{{ source(...) }}` or `{{ ref(...) }}` with early projection/renaming.
2. **Logical / Transformation CTEs**: Isolate business logic, calculations, and joins into distinct, single-purpose steps.
3. **Final CTE**: Assemble final column projections in standard order.
4. **Final Select**: Always end with `select * from final` for auditability and debugging.

*Detailed templates and before/after comparisons:* [CTE Patterns Guide](./references/cte_patterns.md)

### 2. Layer Responsibilities & Materialization
As configured in `dbt_project.yml`:

| Layer | Materialization | Location | Primary Purpose | Rules |
| :--- | :--- | :--- | :--- | :--- |
| **Staging** | `table` (or `incremental`) | `models/staging/` | Cleanse, cast, and persist raw extractions | 1:1 with source table, rename to snake_case, cast datatypes. Materialized as tables (full load) with at least one entity configured as incremental. |
| **Intermediate** | `ephemeral` | `models/intermediate/` | Reusable cross-model transformations | Multi-model joins, complex business rules, prep for multiple marts. |
| **Marts** | `table` | `models/marts/` | Business entities & reporting | Dimensional modeling (facts & dims), aggregations, consumer-ready datasets. |

### 3. Maintainability & Jinja Macros
- **Don't Repeat Yourself (DRY)**: If a SQL calculation, data conversion, or conditional expression is repeated across 2 or more models, extract it into a macro in `macros/`.
- **Expression-First Macros**: Prefer macros that return clean, composable SQL snippets rather than full statement blocks.
- **Leverage Installed Packages**: Check `dbt_utils` before writing custom macros (e.g., `generate_surrogate_key`, `star`, `pivot`).
- **Whitespace Control**: Always use `{%-` and `-%}` to keep compiled SQL clean and human-readable.

*Detailed macro authoring patterns and examples:* [Jinja Macros Guide](./references/jinja_macros.md)

### 4. SQL Syntax & Formatting (Snowflake)
- **Keywords**: Use lowercase for all SQL keywords (`select`, `from`, `where`, `join`, `with`, `as`).
- **Identifiers**: Column names and aliases must be lowercase `snake_case`. Avoid raw uppercase Snowflake identifiers in models.
- **Explicit Casting**: Always cast raw types explicitly using `cast(col as type)` or `col::type`. Prefer safe casts (`try_cast`) when handling untrusted string inputs.
- **No Subqueries in FROM/WHERE**: Replace all nested subqueries with named CTEs.

---

## Verification & Tooling Workflow

> [!IMPORTANT]
> Always execute dbt commands inside the **`dbt-snowflake`** Conda environment:
> ```powershell
> conda activate dbt-snowflake
> # OR run directly via conda run:
> conda run -n dbt-snowflake dbt <command>
> ```

Before completing model changes, follow this verification flow:

```powershell
# 1. Compile model and check compiled SQL output
conda run -n dbt-snowflake dbt compile -s <model_name>

# 2. Run SQLFluff linter
sqlfluff lint models/.../<model_name>.sql

# 3. Automatically fix linting issues where possible
sqlfluff fix models/.../<model_name>.sql

# 4. Build and test model in dev
conda run -n dbt-snowflake dbt build -s <model_name>
```
