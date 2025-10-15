-- Analysis for multiple campaigns and channels
-- This model analyzes performance across multiple campaigns and channels

{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filters=['summer_campaign_2024', 'winter_campaign_2024'],
    channel_filters=['email', 'text', 'push'],
    n_time_period=7,
    target_metrics=['email_send', 'text_send']
) }}
