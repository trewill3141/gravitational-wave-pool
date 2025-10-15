{% macro generate_metric_analysis_advanced(
    source_table,
    time_period='day',
    campaign_filter=none,
    channel_filter=none,
    metric_filter=none,
    n_day_lookback=7,
    target_metrics=['email_send', 'text_send', 'email_open', 'applications_submitted']
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
        email_send,
        text_send,
        email_open,
        applications_submitted,
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
    {% if campaign_filter %}
        and campaign_key = '{{ campaign_filter }}'
    {% endif %}
    {% if channel_filter %}
        and channel_key = '{{ channel_filter }}'
    {% endif %}
    {% if metric_filter %}
        and metric_name = '{{ metric_filter }}'
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
        sum(email_send) as email_send_total,
        sum(text_send) as text_send_total,
        sum(email_open) as email_open_total,
        sum(applications_submitted) as applications_submitted_total
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

-- Calculate the n-day average for the same day of week/hour
n_day_averages as (
    select 
        date,
        channel,
        campaign,
        metric,
        email_send_total,
        text_send_total,
        email_open_total,
        applications_submitted_total,
        {% if time_period == 'day' %}
        -- For daily analysis, compare same day of week (e.g., Monday to Monday)
        avg(email_send_total) over (
            partition by channel, campaign, metric, day_of_week
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_send_n_day_avg,
        avg(text_send_total) over (
            partition by channel, campaign, metric, day_of_week
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as text_send_n_day_avg,
        avg(email_open_total) over (
            partition by channel, campaign, metric, day_of_week
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_open_n_day_avg,
        avg(applications_submitted_total) over (
            partition by channel, campaign, metric, day_of_week
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as applications_submitted_n_day_avg
        {% elif time_period == 'week' %}
        -- For weekly analysis, compare same week of year
        avg(email_send_total) over (
            partition by channel, campaign, metric, week_of_year
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_send_n_day_avg,
        avg(text_send_total) over (
            partition by channel, campaign, metric, week_of_year
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as text_send_n_day_avg,
        avg(email_open_total) over (
            partition by channel, campaign, metric, week_of_year
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_open_n_day_avg,
        avg(applications_submitted_total) over (
            partition by channel, campaign, metric, week_of_year
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as applications_submitted_n_day_avg
        {% elif time_period == 'hour' %}
        -- For hourly analysis, compare same hour of day
        avg(email_send_total) over (
            partition by channel, campaign, metric, hour_of_day
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_send_n_day_avg,
        avg(text_send_total) over (
            partition by channel, campaign, metric, hour_of_day
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as text_send_n_day_avg,
        avg(email_open_total) over (
            partition by channel, campaign, metric, hour_of_day
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_open_n_day_avg,
        avg(applications_submitted_total) over (
            partition by channel, campaign, metric, hour_of_day
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as applications_submitted_n_day_avg
        {% else %}
        -- For minute analysis, just use rolling average
        avg(email_send_total) over (
            partition by channel, campaign, metric
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_send_n_day_avg,
        avg(text_send_total) over (
            partition by channel, campaign, metric
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as text_send_n_day_avg,
        avg(email_open_total) over (
            partition by channel, campaign, metric
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_open_n_day_avg,
        avg(applications_submitted_total) over (
            partition by channel, campaign, metric
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as applications_submitted_n_day_avg
        {% endif %}
    from aggregated_metrics
),

-- Dynamic unpivoting based on target_metrics
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
        {{ metric }}_n_day_avg as n_day_average,
        case 
            when {{ metric }}_n_day_avg > 0 
            then {{ metric }}_total / {{ metric }}_n_day_avg 
            else null 
        end as comparison
    from n_day_averages
    where {{ metric }}_total > 0
{% endfor %}
)

select 
    date,
    channel,
    campaign,
    metric,
    total,
    n_day_average,
    comparison,
    -- Additional calculated fields
    case 
        when comparison > 1.2 then 'Above Average'
        when comparison < 0.8 then 'Below Average'
        else 'Average'
    end as performance_category,
    case 
        when comparison > 1.2 then 'green'
        when comparison < 0.8 then 'red'
        else 'yellow'
    end as performance_color
from unpivoted_metrics
order by date desc, channel, campaign, metric

{% endmacro %}
