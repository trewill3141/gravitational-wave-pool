{% macro safe_divide(numerator, denominator, default_value=0) %}
    case 
        when {{ denominator }} = 0 or {{ denominator }} is null 
        then {{ default_value }}
        else {{ numerator }} / {{ denominator }}
    end
{% endmacro %}

{% macro calculate_growth_rate(current_value, previous_value) %}
    {{ safe_divide(
        current_value - previous_value,
        previous_value,
        0
    ) }}
{% endmacro %}

{% macro format_percentage(value, decimal_places=2) %}
    round({{ value }} * 100, {{ decimal_places }})
{% endmacro %}

{% macro get_performance_category(comparison_value) %}
    case 
        when {{ comparison_value }} > 1.2 then 'Above Average'
        when {{ comparison_value }} < 0.8 then 'Below Average'
        else 'Average'
    end
{% endmacro %}

{% macro get_performance_color(comparison_value) %}
    case 
        when {{ comparison_value }} > 1.2 then 'green'
        when {{ comparison_value }} < 0.8 then 'red'
        else 'yellow'
    end
{% endmacro %}

{% macro get_day_of_week_name(date_column) %}
    case dayofweek({{ date_column }})
        when 1 then 'Sunday'
        when 2 then 'Monday'
        when 3 then 'Tuesday'
        when 4 then 'Wednesday'
        when 5 then 'Thursday'
        when 6 then 'Friday'
        when 7 then 'Saturday'
    end
{% endmacro %}
