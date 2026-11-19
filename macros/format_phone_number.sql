{% macro format_phone_number(column_name) -%}
    case
        when {{ column_name }} is null then null
        when charindex('-', {{ column_name }}) = 0 then {{ column_name }}
        else concat(
            '+',
            split_part({{ column_name }}, '-', 1),
            '-',
            replace(substr({{ column_name }}, charindex('-', {{ column_name }}) + 1), '-', '')
        )
    end
{%- endmacro %}

{% macro format_phone(column_name) -%}
    {{ format_phone_number(column_name) }}
{%- endmacro %}

{% macro get_phone_prefix(column_name) -%}
    split_part({{ column_name }}, '-', 1)
{%- endmacro %}
