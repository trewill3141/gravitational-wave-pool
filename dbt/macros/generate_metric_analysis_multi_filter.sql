{% macro generate_metric_analysis_multi_filter(
    source_table,
    time_period='day',
    campaign_filters=none,
    channel_filters=none,
    metric_filters=none,
    n_time_period=7,
    target_metrics=['email_send']
) %}

{%- set time_periods = {
    'minute': 'minute',
    'hour': 'hour', 
    'day': 'day',
    'week': 'week'
} -%}

{%- set time_period_key = time_periods[time_period] -%}

with base_data as (
    select 
        event_timestamp,
        channel_key,
        campaign_key,
        metric_name,
        {% for metric in target_metrics %}
        {{ metric }}{% if not loop.last %},{% endif %}
        {% endfor %},
        date_trunc('{{ time_period_key }}', event_timestamp) as period_start,
        {% if time_period == 'day' %}
        dayofweek(event_timestamp) as day_of_week
        {% elif time_period == 'week' %}
        week(event_timestamp) as week_of_year
        {% elif time_period == 'hour' %}
        hour(event_timestamp) as hour_of_day
        {% endif %}
    from {{ source_table }}
    where 1=1
    {% if campaign_filters %}
        {% if campaign_filters is string %}
            and campaign_key = '{{ campaign_filters }}'
        {% else %}
            and campaign_key in (
                {% for campaign in campaign_filters %}
                '{{ campaign }}'{% if not loop.last %},{% endif %}
                {% endfor %}
            )
        {% endif %}
    {% endif %}
    {% if channel_filters %}
        {% if channel_filters is string %}
            and channel_key = '{{ channel_filters }}'
        {% else %}
            and channel_key in (
                {% for channel in channel_filters %}
                '{{ channel }}'{% if not loop.last %},{% endif %}
                {% endfor %}
            )
        {% endif %}
    {% endif %}
    {% if metric_filters %}
        {% if metric_filters is string %}
            and metric_name = '{{ metric_filters }}'
        {% else %}
            and metric_name in (
                {% for metric in metric_filters %}
                '{{ metric }}'{% if not loop.last %},{% endif %}
                {% endfor %}
            )
        {% endif %}
    {% endif %}
),

aggregated_metrics as (
    select 
        period_start as date,
        channel_key as channel,
        campaign_key as campaign,
        metric_name as metric,
        {% if time_period == 'day' %}
        day_of_week,
        {% elif time_period == 'week' %}
        week_of_year,
        {% elif time_period == 'hour' %}
        hour_of_day,
        {% endif %}
        {% for metric in target_metrics %}
        sum({{ metric }}) as {{ metric }}_total{% if not loop.last %},{% endif %}
        {% endfor %}
    from base_data
    group by 1, 2, 3, 4
    {% if time_period == 'day' %}
    , 5
    {% elif time_period == 'week' %}
    , 5
    {% elif time_period == 'hour' %}
    , 5
    {% endif %}
),

-- Calculate the n-time-period average for the same day of week/hour
n_time_period_averages as (
    select 
        date,
        channel,
        campaign,
        metric,
        {% for metric in target_metrics %}
        {{ metric }}_total,
        {% if time_period == 'day' %}
        -- For daily analysis, compare same day of week (e.g., Monday to Monday)
        avg({{ metric }}_total) over (
            partition by channel, campaign, metric, day_of_week
            order by date
            rows between {{ n_time_period }} preceding and 1 preceding
        ) as {{ metric }}_n_time_period_avg{% if not loop.last %},{% endif %}
        {% elif time_period == 'week' %}
        -- For weekly analysis, compare same week of year
        avg({{ metric }}_total) over (
            partition by channel, campaign, metric, week_of_year
            order by date
            rows between {{ n_time_period }} preceding and 1 preceding
        ) as {{ metric }}_n_time_period_avg{% if not loop.last %},{% endif %}
        {% elif time_period == 'hour' %}
        -- For hourly analysis, compare same hour of day
        avg({{ metric }}_total) over (
            partition by channel, campaign, metric, hour_of_day
            order by date
            rows between {{ n_time_period }} preceding and 1 preceding
        ) as {{ metric }}_n_time_period_avg{% if not loop.last %},{% endif %}
        {% else %}
        -- For minute analysis, just use rolling average
        avg({{ metric }}_total) over (
            partition by channel, campaign, metric
            order by date
            rows between {{ n_time_period }} preceding and 1 preceding
        ) as {{ metric }}_n_time_period_avg{% if not loop.last %},{% endif %}
        {% endif %}
        {% endfor %}
    from aggregated_metrics
),

-- Dynamic unpivoting based on target_metrics - only process requested metrics
{% for metric in target_metrics %}
{% if loop.first %}
unpivoted_metrics as (
{% else %}
union all
{% endif %}
    select 
        date,
        channel,
        campaign,
        '{{ metric }}' as metric,
        {{ metric }}_total as total,
        {{ metric }}_n_time_period_avg as n_time_period_average,
        case 
            when {{ metric }}_n_time_period_avg > 0 
            then {{ metric }}_total / {{ metric }}_n_time_period_avg 
            else null 
        end as comparison,
        -- Additional calculated fields
        case 
            when {{ metric }}_total / nullif({{ metric }}_n_time_period_avg, 0) > 1.2 then 'Above Average'
            when {{ metric }}_total / nullif({{ metric }}_n_time_period_avg, 0) < 0.8 then 'Below Average'
            else 'Average'
        end as performance_category,
        case 
            when {{ metric }}_total / nullif({{ metric }}_n_time_period_avg, 0) > 1.2 then 'green'
            when {{ metric }}_total / nullif({{ metric }}_n_time_period_avg, 0) < 0.8 then 'red'
            else 'yellow'
        end as performance_color
    from n_time_period_averages
    where {{ metric }}_total > 0
{% endfor %}
)

select 
    date,
    channel,
    campaign,
    metric,
    total,
    n_time_period_average,
    comparison,
    performance_category,
    performance_color
from unpivoted_metrics
order by date desc, channel, campaign, metric

{% endmacro %}
