# Looker Model: Marketing Metrics
# Data Engineering Director - Prototyping Repository

connection: "snowflake_connection"

# Include all views
include: "*.view"

# Define the model
datagroup: marketing_metrics_datagroup {
  sql_trigger: SELECT MAX(updated_at) FROM raw.events;;
  max_cache_age: "1 hour"
}

# Define explores
explore: marketing_campaigns {
  label: "Marketing Campaigns"
  description: "Analysis of marketing campaign performance and metrics"
  
  # Join with related explores
  join: campaign_channels {
    type: left_outer
    sql_on: ${marketing_campaigns.campaign_key} = ${campaign_channels.campaign_key} ;;
    relationship: one_to_many
  }
  
  join: daily_metrics {
    type: left_outer
    sql_on: ${marketing_campaigns.campaign_key} = ${daily_metrics.campaign_key} 
      AND ${marketing_campaigns.date} = ${daily_metrics.date} ;;
    relationship: one_to_many
  }
  
  # Define filters
  filter: date_range {
    type: date
    default_value: "30 days"
  }
  
  filter: campaign_filter {
    type: string
    suggest_explore: marketing_campaigns
    suggest_dimension: marketing_campaigns.campaign_name
  }
  
  filter: channel_filter {
    type: string
    suggest_explore: campaign_channels
    suggest_dimension: campaign_channels.channel_name
  }
  
  # Define measures
  measure: total_email_sends {
    type: sum
    sql: ${TABLE}.email_send ;;
    value_format_name: decimal_0
    label: "Total Email Sends"
  }
  
  measure: total_applications {
    type: sum
    sql: ${TABLE}.applications_submitted ;;
    value_format_name: decimal_0
    label: "Total Applications"
  }
  
  measure: email_open_rate {
    type: number
    sql: ${email_opens} / NULLIF(${email_sends}, 0) ;;
    value_format_name: percent_1
    label: "Email Open Rate"
  }
  
  measure: application_conversion_rate {
    type: number
    sql: ${applications_submitted} / NULLIF(${email_sends}, 0) ;;
    value_format_name: percent_2
    label: "Application Conversion Rate"
  }
  
  # Define dimensions
  dimension: campaign_key {
    type: string
    primary_key: yes
    sql: ${TABLE}.campaign_key ;;
    label: "Campaign Key"
  }
  
  dimension: campaign_name {
    type: string
    sql: ${TABLE}.campaign_name ;;
    label: "Campaign Name"
  }
  
  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
    label: "Date"
  }
  
  dimension: total_sends {
    type: number
    sql: ${TABLE}.email_send + ${TABLE}.text_send ;;
    value_format_name: decimal_0
    label: "Total Sends"
  }
  
  dimension: total_opens {
    type: number
    sql: ${TABLE}.email_open ;;
    value_format_name: decimal_0
    label: "Total Opens"
  }
}

# Additional explores
explore: campaign_performance {
  label: "Campaign Performance Analysis"
  description: "Detailed performance analysis by campaign and time period"
  
  join: weekly_metrics {
    type: left_outer
    sql_on: ${campaign_performance.campaign_key} = ${weekly_metrics.campaign_key} ;;
    relationship: one_to_many
  }
  
  # Performance measures
  measure: weekly_growth_rate {
    type: number
    sql: (${total_sends} - LAG(${total_sends}, 1) OVER (PARTITION BY ${campaign_key} ORDER BY ${date})) / NULLIF(LAG(${total_sends}, 1) OVER (PARTITION BY ${campaign_key} ORDER BY ${date}), 0) ;;
    value_format_name: percent_2
    label: "Weekly Growth Rate"
  }
  
  measure: performance_score {
    type: number
    sql: (${email_open_rate} * 0.4) + (${application_conversion_rate} * 0.6) ;;
    value_format_name: decimal_2
    label: "Performance Score"
  }
}
