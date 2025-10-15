-- Optimized analysis for email-related metrics only
-- This model only processes email_send and email_open data

{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='day',
    n_time_period=7,
    target_metrics=['email_send', 'email_open']
) }}
