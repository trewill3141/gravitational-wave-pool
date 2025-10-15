-- Optimized analysis for a specific campaign and metric
-- This model demonstrates filtering by campaign and analyzing only one metric

{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filter='summer_campaign_2024',
    channel_filter='email',
    n_time_period=7,
    target_metrics=['email_send']
) }}
