-- Optimized analysis for email_send metric only
-- This model only processes email_send data, making it much more efficient

{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='day',
    n_time_period=7,
    target_metrics=['email_send']
) }}
