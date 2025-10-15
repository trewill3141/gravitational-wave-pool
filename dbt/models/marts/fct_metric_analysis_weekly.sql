-- Weekly metric analysis using the generate_metric_analysis macro
-- This model creates the analysis for all campaigns and channels on a weekly basis

{{ generate_metric_analysis_advanced(
    source_table=ref('stg_example'),
    time_period='week',
    n_day_lookback=4,  -- Compare to last 4 weeks
    target_metrics=['email_send', 'text_send', 'email_open', 'applications_submitted']
) }}
