# Looker Explore: Campaign Analysis
# Comprehensive campaign performance analysis

explore: campaign_analysis {
  label: "Campaign Analysis"
  description: "Deep dive analysis of marketing campaign performance across all channels and time periods"
  
  # Join with channel data
  join: channel_performance {
    type: left_outer
    sql_on: ${campaign_analysis.campaign_key} = ${channel_performance.campaign_key} ;;
    relationship: one_to_many
  }
  
  # Join with user behavior data
  join: user_behavior {
    type: left_outer
    sql_on: ${campaign_analysis.campaign_key} = ${user_behavior.campaign_key} 
      AND ${campaign_analysis.date} = ${user_behavior.date} ;;
    relationship: one_to_many
  }
  
  # Advanced filters
  filter: performance_threshold {
    type: number
    default_value: "0.1"
    label: "Minimum Performance Score"
  }
  
  filter: channel_type {
    type: string
    suggest_explore: channel_performance
    suggest_dimension: channel_performance.channel_type
  }
  
  # Cohort analysis measures
  measure: cohort_retention_rate {
    type: number
    sql: ${retained_users} / NULLIF(${cohort_size}, 0) ;;
    value_format_name: percent_2
    label: "Cohort Retention Rate"
  }
  
  measure: lifetime_value {
    type: number
    sql: ${total_revenue} / NULLIF(${unique_users}, 0) ;;
    value_format_name: currency_usd
    label: "Customer Lifetime Value"
  }
  
  # Advanced dimensions
  dimension: campaign_lifecycle_stage {
    type: tier
    tiers: [1, 7, 14, 30, 90]
    style: integer
    sql: DATEDIFF('day', ${launch_date}, ${date}) ;;
    label: "Campaign Lifecycle Stage (Days)"
  }
  
  dimension: performance_tier {
    type: tier
    tiers: [0.1, 0.3, 0.5, 0.7, 0.9]
    style: decimal
    sql: ${performance_score} ;;
    label: "Performance Tier"
  }
  
  # Time-based analysis
  dimension: day_of_week {
    type: string
    sql: DAYNAME(${date}) ;;
    label: "Day of Week"
  }
  
  dimension: hour_of_day {
    type: number
    sql: HOUR(${timestamp}) ;;
    label: "Hour of Day"
  }
}
