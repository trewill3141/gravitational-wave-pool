-- Filtered metric analysis using the generate_metric_analysis macro
-- This model demonstrates how to use the macro with specific filters

{{ generate_metric_analysis_advanced(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filter='summer_campaign_2024',
    channel_filter='email',
    metric_filter='marketing',
    n_day_lookback=7,
    target_metrics=['email_send', 'email_open', 'applications_submitted']
) }}
