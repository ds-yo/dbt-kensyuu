{% macro month_format(column_name) %}
    to_char({{ column_name }}, 'yyyy-mm')
{% endmacro %}
