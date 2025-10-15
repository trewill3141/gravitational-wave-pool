{% macro generate_metric_analysis(
    source_table,
    time_period='day',
    campaign_filter=none,
    channel_filter=none,
    metric_filter=none,
    n_day_lookback=7
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
        date_trunc('{{ time_period_key }}', event_timestamp) as period_start
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
        sum(email_send) as email_send_total,
        sum(text_send) as text_send_total,
        sum(email_open) as email_open_total,
        sum(applications_submitted) as applications_submitted_total
    from base_data
    group by 1, 2, 3, 4
),

-- Calculate the n-day average for the same day of week
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
        -- Calculate average for the same day of week over the last n periods
        {% if time_period == 'day' %}
        avg(email_send_total) over (
            partition by channel, campaign, metric, dayofweek(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_send_n_day_avg,
        avg(text_send_total) over (
            partition by channel, campaign, metric, dayofweek(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as text_send_n_day_avg,
        avg(email_open_total) over (
            partition by channel, campaign, metric, dayofweek(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_open_n_day_avg,
        avg(applications_submitted_total) over (
            partition by channel, campaign, metric, dayofweek(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as applications_submitted_n_day_avg
        {% elif time_period == 'week' %}
        avg(email_send_total) over (
            partition by channel, campaign, metric, week(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_send_n_day_avg,
        avg(text_send_total) over (
            partition by channel, campaign, metric, week(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as text_send_n_day_avg,
        avg(email_open_total) over (
            partition by channel, campaign, metric, week(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_open_n_day_avg,
        avg(applications_submitted_total) over (
            partition by channel, campaign, metric, week(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as applications_submitted_n_day_avg
        {% elif time_period == 'hour' %}
        avg(email_send_total) over (
            partition by channel, campaign, metric, hour(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_send_n_day_avg,
        avg(text_send_total) over (
            partition by channel, campaign, metric, hour(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as text_send_n_day_avg,
        avg(email_open_total) over (
            partition by channel, campaign, metric, hour(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as email_open_n_day_avg,
        avg(applications_submitted_total) over (
            partition by channel, campaign, metric, hour(date)
            order by date
            rows between {{ n_day_lookback }} preceding and 1 preceding
        ) as applications_submitted_n_day_avg
        {% else %}
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

-- Unpivot the metrics to get the desired structure
unpivoted_metrics as (
    select 
        date,
        channel,
        campaign,
        'email_send' as metric,
        email_send_total as total,
        email_send_n_day_avg as n_day_average,
        case 
            when email_send_n_day_avg > 0 
            then email_send_total / email_send_n_day_avg 
            else null 
        end as comparison
    from n_day_averages
    
    union all
    
    select 
        date,
        channel,
        campaign,
        'text_send' as metric,
        text_send_total as total,
        text_send_n_day_avg as n_day_average,
        case 
            when text_send_n_day_avg > 0 
            then text_send_total / text_send_n_day_avg 
            else null 
        end as comparison
    from n_day_averages
    
    union all
    
    select 
        date,
        channel,
        campaign,
        'email_open' as metric,
        email_open_total as total,
        email_open_n_day_avg as n_day_average,
        case 
            when email_open_n_day_avg > 0 
            then email_open_total / email_open_n_day_avg 
            else null 
        end as comparison
    from n_day_averages
    
    union all
    
    select 
        date,
        channel,
        campaign,
        'applications_submitted' as metric,
        applications_submitted_total as total,
        applications_submitted_n_day_avg as n_day_average,
        case 
            when applications_submitted_n_day_avg > 0 
            then applications_submitted_total / applications_submitted_n_day_avg 
            else null 
        end as comparison
    from n_day_averages
)

select 
    date,
    channel,
    campaign,
    metric,
    total,
    n_day_average,
    comparison
from unpivoted_metrics
where total > 0  -- Only include rows with actual data
order by date desc, channel, campaign, metric

{% endmacro %}
