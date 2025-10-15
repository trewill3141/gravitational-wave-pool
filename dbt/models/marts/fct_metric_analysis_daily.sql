-- Daily metric analysis using the generate_metric_analysis macro
-- This model creates the analysis for all campaigns and channels on a daily basis

{{ generate_metric_analysis_advanced(
    source_table=ref('stg_example'),
    time_period='day',
    n_day_lookback=7,
    target_metrics=['email_send', 'text_send', 'email_open', 'applications_submitted']
) }}
