-- Single campaign with multiple channels and metrics
-- This model shows how to use the multi-filter macro for a single campaign

{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filters='summer_campaign_2024',  -- Single campaign as string
    channel_filters=['email', 'text'],       -- Multiple channels as list
    n_time_period=7,
    target_metrics=['email_send', 'email_open', 'applications_submitted']
) }}
