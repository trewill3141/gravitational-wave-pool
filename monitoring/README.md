# Monitoring and Observability

This directory contains monitoring configurations for the data engineering platform.

## Directory Structure

```
monitoring/
├── prometheus/        # Prometheus configuration
├── grafana/          # Grafana dashboards and datasources
├── alerts/           # Alert rules and configurations
├── logs/             # Log aggregation setup
└── README.md         # This file
```

## Components

### Prometheus (`prometheus/`)
- **`prometheus.yml`** - Main Prometheus configuration
  - Scrape configurations for all services
  - Alert manager integration
  - Rule file definitions

### Grafana (`grafana/`)
- **`dashboards/`** - Dashboard definitions
  - Data engineering overview dashboard
  - System health monitoring
  - Business metrics visualization
- **`datasources/`** - Data source configurations
  - Snowflake connection
  - Prometheus metrics
  - Custom application metrics

### Alerts (`alerts/`)
- **`data_quality_alerts.yml`** - Data quality monitoring
  - DBT test failures
  - Airflow DAG failures
  - Data freshness issues
  - Replication lag detection

## Key Features

### Data Engineering Monitoring
- **DBT Metrics**: Model runs, test results, execution times
- **Airflow Metrics**: DAG status, task performance, resource usage
- **Snowflake Metrics**: Query performance, warehouse usage, costs
- **Data Quality**: Test results, data freshness, validation metrics

### System Health Monitoring
- **Resource Usage**: CPU, memory, disk space
- **Container Health**: Docker container status and performance
- **Network Monitoring**: Connectivity and latency metrics
- **Storage Monitoring**: Disk usage and I/O performance

### Business Metrics Monitoring
- **Conversion Rates**: Application and email conversion tracking
- **Campaign Performance**: Marketing campaign effectiveness
- **User Behavior**: Engagement and retention metrics
- **Revenue Tracking**: Financial performance indicators

## Alert Rules

### Data Quality Alerts
- **DBT Test Failure**: Immediate alert for test failures
- **Model Run Failure**: Critical alert for model execution failures
- **Data Freshness**: Warning for stale data (>6 hours)
- **Replication Lag**: Alert for replication delays (>2 hours)

### System Health Alerts
- **High Memory Usage**: Warning at 80% memory usage
- **High CPU Usage**: Warning at 80% CPU usage
- **Disk Space Low**: Critical alert at 10% disk space
- **Container Restart**: Alert for unexpected restarts

### Business Metrics Alerts
- **Conversion Rate Drop**: Warning for 5%+ conversion rate drop
- **Low Email Open Rate**: Warning for open rates below 10%
- **Revenue Decline**: Alert for significant revenue drops
- **User Engagement Drop**: Warning for engagement decreases

## Dashboard Features

### Data Engineering Overview
- **Real-time Metrics**: Live system status and performance
- **Historical Trends**: Performance over time
- **Error Tracking**: Failed jobs and error rates
- **Resource Utilization**: CPU, memory, and storage usage

### Business Intelligence
- **KPI Tracking**: Key performance indicators
- **Campaign Analysis**: Marketing campaign effectiveness
- **User Analytics**: User behavior and engagement
- **Financial Metrics**: Revenue and cost tracking

## Setup and Configuration

### Prometheus Setup
1. Configure scrape targets
2. Set up alert rules
3. Configure alert manager
4. Test metric collection

### Grafana Setup
1. Configure data sources
2. Import dashboard definitions
3. Set up user permissions
4. Configure alerting channels

### Alert Configuration
1. Define alert rules
2. Configure notification channels
3. Set up escalation policies
4. Test alert delivery

## Best Practices

### Monitoring Strategy
- **Comprehensive Coverage**: Monitor all critical components
- **Appropriate Thresholds**: Set realistic alert thresholds
- **Alert Fatigue Prevention**: Avoid too many false positives
- **Regular Review**: Update thresholds and rules regularly

### Performance Optimization
- **Efficient Queries**: Optimize Prometheus queries
- **Dashboard Performance**: Limit dashboard complexity
- **Resource Usage**: Monitor monitoring system resources
- **Data Retention**: Configure appropriate retention policies

### Security
- **Access Controls**: Secure monitoring endpoints
- **Credential Management**: Secure data source credentials
- **Audit Logging**: Log monitoring system access
- **Data Privacy**: Ensure monitoring data privacy

## Integration

### Data Sources
- **Snowflake**: Query performance and usage metrics
- **Airflow**: DAG and task execution metrics
- **DBT**: Model run and test result metrics
- **System**: Container and infrastructure metrics

### Notification Channels
- **Email**: Critical alerts and summaries
- **Slack**: Real-time notifications
- **PagerDuty**: Escalation for critical issues
- **Webhooks**: Custom integrations

## Troubleshooting

### Common Issues
- **Missing Metrics**: Check scrape configurations
- **Alert Noise**: Adjust thresholds and rules
- **Dashboard Performance**: Optimize queries and visualizations
- **Data Gaps**: Investigate metric collection issues

### Debug Commands
```bash
# Check Prometheus targets
curl http://prometheus:9090/api/v1/targets

# Test alert rules
promtool test rules alerts/*.yml

# Check Grafana datasources
curl -H "Authorization: Bearer $GRAFANA_TOKEN" http://grafana:3000/api/datasources
```

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Alert Manager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Monitoring Best Practices](https://prometheus.io/docs/practices/)
