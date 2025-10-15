# Multi-Filter Metric Analysis Macro Usage Guide

## Overview

The `generate_metric_analysis_multi_filter` macro extends the optimized macro to support multiple filters for campaigns, channels, and metrics. This allows you to analyze performance across multiple campaigns or channels in a single query.

## Key Features

- **Multiple Campaign Filters**: Analyze multiple campaigns simultaneously
- **Multiple Channel Filters**: Compare performance across different channels
- **Multiple Metric Filters**: Filter by multiple metric names
- **Flexible Input**: Supports both single values (strings) and lists
- **Backward Compatible**: Works with single values just like the original macro

## Macro Parameters

### Required Parameters
- `source_table`: The source table reference (e.g., `ref('stg_example')`)

### Optional Parameters
- `time_period`: Time granularity ('day', 'week', 'hour', 'minute') - Default: 'day'
- `campaign_filters`: Single campaign (string) or list of campaigns - Default: none
- `channel_filters`: Single channel (string) or list of channels - Default: none
- `metric_filters`: Single metric (string) or list of metrics - Default: none
- `n_time_period`: Number of periods to look back for average - Default: 7
- `target_metrics`: List of metrics to include - Default: ['email_send']

## Usage Examples

### 1. Multiple Campaigns Analysis
```sql
{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filters=['summer_campaign_2024', 'winter_campaign_2024', 'spring_campaign_2024'],
    n_time_period=7,
    target_metrics=['email_send']
) }}
```

### 2. Multiple Channels Analysis
```sql
{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='day',
    channel_filters=['email', 'text', 'push'],
    n_time_period=7,
    target_metrics=['email_send', 'text_send']
) }}
```

### 3. Multiple Campaigns and Channels
```sql
{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filters=['summer_campaign_2024', 'winter_campaign_2024'],
    channel_filters=['email', 'text'],
    n_time_period=7,
    target_metrics=['email_send', 'text_send']
) }}
```

### 4. Mixed Single and Multiple Filters
```sql
{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='day',
    campaign_filters='summer_campaign_2024',  -- Single campaign
    channel_filters=['email', 'text'],       -- Multiple channels
    n_time_period=7,
    target_metrics=['email_send', 'email_open']
) }}
```

### 5. All Filters with Multiple Values
```sql
{{ generate_metric_analysis_multi_filter(
    source_table=ref('stg_example'),
    time_period='week',
    campaign_filters=['campaign_a', 'campaign_b', 'campaign_c'],
    channel_filters=['email', 'text', 'push', 'social'],
    metric_filters=['marketing', 'promotional', 'transactional'],
    n_time_period=4,
    target_metrics=['email_send', 'email_open', 'applications_submitted']
) }}
```

## Filter Logic

### Campaign Filters
- **Single Campaign**: `campaign_filters='summer_campaign_2024'`
- **Multiple Campaigns**: `campaign_filters=['campaign_a', 'campaign_b', 'campaign_c']`
- **SQL Generated**: `campaign_key IN ('campaign_a', 'campaign_b', 'campaign_c')`

### Channel Filters
- **Single Channel**: `channel_filters='email'`
- **Multiple Channels**: `channel_filters=['email', 'text', 'push']`
- **SQL Generated**: `channel_key IN ('email', 'text', 'push')`

### Metric Filters
- **Single Metric**: `metric_filters='marketing'`
- **Multiple Metrics**: `metric_filters=['marketing', 'promotional']`
- **SQL Generated**: `metric_name IN ('marketing', 'promotional')`

## Performance Considerations

### When to Use Multi-Filter vs Single Filter

**Use Multi-Filter When:**
- Comparing performance across multiple campaigns
- Analyzing multiple channels simultaneously
- Need to filter by multiple metric names
- Want to reduce the number of separate queries

**Use Single Filter When:**
- Analyzing only one campaign/channel/metric
- Need maximum performance for single-item analysis
- Simple, focused analysis

### Performance Tips

1. **Limit Campaign List**: Don't include too many campaigns (10+ can impact performance)
2. **Use Appropriate Time Periods**: Shorter time periods for more campaigns
3. **Filter Early**: Use other filters to reduce data before multi-filtering
4. **Index Considerations**: Ensure proper indexing on filter columns

## Output Structure

The macro returns the same structure as the optimized version:

| Column | Description |
|--------|-------------|
| `date` | Time period |
| `channel` | Marketing channel |
| `campaign` | Campaign identifier |
| `metric` | Specific metric |
| `total` | Current period value |
| `n_time_period_average` | Average of same period over last N periods |
| `comparison` | Ratio of total to average |
| `performance_category` | Above/Below/Average |
| `performance_color` | Green/Yellow/Red |

## Use Cases

### 1. Campaign Performance Comparison
Compare email send performance across multiple campaigns to identify top performers.

### 2. Channel Analysis
Analyze which channels perform best for specific metrics across all campaigns.

### 3. Seasonal Campaign Analysis
Compare summer vs winter campaigns across multiple channels and metrics.

### 4. A/B Testing
Compare performance of different campaign variants or channel strategies.

### 5. Executive Dashboards
Create comprehensive views that show performance across multiple dimensions.

## Best Practices

1. **Start Simple**: Begin with single filters, then add multiple filters as needed
2. **Use Meaningful Names**: Choose descriptive campaign and channel names
3. **Monitor Performance**: Watch query execution times with large filter lists
4. **Document Filter Logic**: Keep track of which campaigns/channels are included
5. **Test Incrementally**: Test with small filter lists before scaling up

## Troubleshooting

### Common Issues

1. **No Data Returned**: Check that filter values exist in your source data
2. **Performance Issues**: Reduce the number of filters or use more specific time periods
3. **Unexpected Results**: Verify filter values match exactly (case-sensitive)

### Data Requirements

- Source table must have `campaign_key`, `channel_key`, and `metric_name` columns
- Filter values must match exactly (case-sensitive)
- Sufficient historical data for the specified `n_time_period`
