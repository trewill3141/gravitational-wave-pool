# Metric Analysis Macro Usage Guide

## Overview

The `generate_metric_analysis_optimized` macro creates a standardized analysis table with the following columns:

> **Performance Note**: The optimized version only processes the metrics you specify in `target_metrics`, making it much more efficient than processing all metrics when you only need one or two.
- `date`: The time period (day, week, hour, or minute)
- `channel`: The marketing channel
- `campaign`: The campaign identifier
- `metric`: The specific metric being analyzed
- `total`: The total value for the current period
- `n_time_period_average`: The average value for the same period over the last N periods
- `comparison`: The ratio of total to n_time_period_average
- `performance_category`: Categorical performance indicator
- `performance_color`: Color coding for dashboards

## Macro Parameters

### Required Parameters
- `source_table`: The source table reference (e.g., `ref('stg_example')`)

### Optional Parameters
- `time_period`: Time granularity ('day', 'week', 'hour', 'minute') - Default: 'day'
- `campaign_filter`: Filter by specific campaign key - Default: none
- `channel_filter`: Filter by specific channel key - Default: none
- `metric_filter`: Filter by specific metric name - Default: none
- `n_time_period`: Number of periods to look back for average - Default: 7
- `target_metrics`: List of metrics to include - Default: all metrics

## Usage Examples

### 1. Daily Analysis for Single Metric (Optimized)
```sql
{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='day',
    n_time_period=7,
    target_metrics=['email_send']
) }}
```

### 2. Weekly Analysis for Specific Campaign (Optimized)
```sql
{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='week',
    campaign_filter='summer_campaign_2024',
    n_time_period=4,
    target_metrics=['applications_submitted']
) }}
```

### 3. Hourly Analysis for Specific Channel and Metric (Optimized)
```sql
{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='hour',
    channel_filter='email',
    metric_filter='marketing',
    n_time_period=24,
    target_metrics=['email_send']
) }}
```

### 4. Multiple Related Metrics (Optimized)
```sql
{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='day',
    target_metrics=['email_send', 'email_open'],
    n_day_lookback=7
) }}
```

### 5. Single Metric with All Filters (Most Optimized)
```sql
{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filter='summer_campaign_2024',
    channel_filter='email',
    metric_filter='marketing',
    n_time_period=7,
    target_metrics=['email_send']
) }}
```

## Time Period Logic

### Daily Analysis
- Compares the same day of the week (e.g., Monday to Monday)
- Uses `dayofweek()` function to group by day of week
- Example: Current Monday compared to average of last 7 Mondays

### Weekly Analysis
- Compares the same week of the year
- Uses `week()` function to group by week of year
- Example: Current week compared to average of last 4 weeks

### Hourly Analysis
- Compares the same hour of the day
- Uses `hour()` function to group by hour
- Example: Current 2 PM compared to average of last 24 hours at 2 PM

### Minute Analysis
- Uses rolling average without day-of-week grouping
- Example: Current minute compared to average of last 60 minutes

## Performance Categories

The macro automatically categorizes performance:
- **Above Average**: comparison > 1.2 (green)
- **Average**: 0.8 ≤ comparison ≤ 1.2 (yellow)
- **Below Average**: comparison < 0.8 (red)

## Performance Optimization

### Why Use the Optimized Version?

The `generate_metric_analysis_optimized` macro provides significant performance improvements:

**Before (Advanced Version):**
- Always processes all 4 metrics: `email_send`, `text_send`, `email_open`, `applications_submitted`
- Creates 4 rows per time period even if you only need 1 metric
- Wastes compute resources on unused metrics

**After (Optimized Version):**
- Only processes metrics specified in `target_metrics`
- Creates 1 row per time period for single metric analysis
- Reduces compute time by up to 75% for single metric queries

### Performance Examples:

```sql
-- ❌ Inefficient: Processes all 4 metrics when you only need 1
{{ generate_metric_analysis_advanced(
    source_table=ref('stg_example'),
    target_metrics=['email_send']  -- Still processes all metrics internally
) }}

-- ✅ Efficient: Only processes the 1 metric you need
{{ generate_metric_analysis_optimized(
    source_table=ref('stg_example'),
    target_metrics=['email_send']  -- Only processes email_send
) }}
```

## Best Practices

1. **Use the optimized version for single metric analysis**:
   - Use `generate_metric_analysis_optimized` when you need 1-2 specific metrics
   - Use `generate_metric_analysis_advanced` only when you need all metrics

2. **Use appropriate lookback periods**:
   - Daily: 7 periods (1 week)
   - Weekly: 4 periods (1 month)
   - Hourly: 24 periods (1 day)
   - Minute: 60 periods (1 hour)

3. **Filter data appropriately**:
   - Use campaign_filter for campaign-specific analysis
   - Use channel_filter for channel-specific analysis
   - Use metric_filter for metric-specific analysis

4. **Select relevant metrics**:
   - Only include metrics that are relevant to your analysis
   - This improves performance and reduces noise

5. **Consider data freshness**:
   - Ensure your source table has sufficient historical data
   - The macro needs at least `n_time_period + 1` periods of data

## Troubleshooting

### Common Issues

1. **No data returned**: Check that your filters are not too restrictive
2. **Null comparisons**: Ensure there's sufficient historical data
3. **Performance issues**: Consider reducing the lookback period or adding more filters

### Data Requirements

- Source table must have `event_timestamp` column
- Source table must have metric columns: `email_send`, `text_send`, `email_open`, `applications_submitted`
- Source table must have dimension columns: `channel_key`, `campaign_key`, `metric_name`
- Historical data must be available for the specified lookback period
