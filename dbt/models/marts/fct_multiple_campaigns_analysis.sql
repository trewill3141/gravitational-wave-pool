-- Analysis for multiple campaigns using the multi-filter macro
-- This model analyzes email_send performance across multiple campaigns

{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filters=['summer_campaign_2024', 'winter_campaign_2024', 'spring_campaign_2024'],
    n_time_period=7,
    target_metrics=['email_send']
) }}
