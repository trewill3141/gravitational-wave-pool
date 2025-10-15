-- Optimized analysis for applications_submitted metric only
-- This model only processes applications_submitted data

{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='day',
    n_time_period=7,
    target_metrics=['applications_submitted']
) }}
