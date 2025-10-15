# Quick Start Guide

## 🚀 Get Up and Running in 15 Minutes

This guide will help you quickly set up and run the data engineering prototyping platform.

## Prerequisites

- Docker and Docker Compose
- Python 3.8+
- Git
- Snowflake account (optional for full functionality)

## Quick Setup

### 1. Clone and Setup
```bash
git clone <repository-url>
cd gravitational-wave-pool
cp env.example .env
# Edit .env with your credentials
```

### 2. Start Core Services
```bash
# Start Airflow and PostgreSQL
docker-compose up -d

# Wait for services to be ready (2-3 minutes)
docker-compose logs -f
```

### 3. Access Services
- **Airflow UI**: http://localhost:8080 (admin/admin)
- **PostgreSQL**: localhost:5432 (airflow/airflow)

### 4. Run DBT (Optional)
```bash
cd dbt
pip install dbt-snowflake
dbt deps
dbt debug  # Test connection
dbt run    # Run models
```

## What You Get

### 🏗️ **Complete Data Platform**
- **DBT**: Data transformation with advanced macros
- **Airflow**: Workflow orchestration
- **Snowflake**: Data warehouse (with your credentials)
- **Monitoring**: Prometheus + Grafana
- **BI**: Looker dashboards
- **Security**: Permifrost permissions

### 📊 **Sample Data Pipeline**
- Marketing campaign analysis
- Email performance metrics
- Application conversion tracking
- Real-time monitoring dashboards

### 🔧 **Advanced Features**
- **Multi-campaign analysis** with flexible filtering
- **Data quality validation** with Great Expectations
- **Infrastructure as Code** with Terraform
- **CI/CD pipelines** for GitHub Actions and Jenkins

## Next Steps

### 1. Explore the Code
```bash
# DBT models and macros
ls dbt/models/
ls dbt/macros/

# Airflow DAGs
ls airflow/dags/

# Monitoring configurations
ls monitoring/
```

### 2. Customize for Your Data
```bash
# Update source data in DBT
vim dbt/models/sources.yml

# Modify Airflow DAGs
vim airflow/dags/example_dbt_dag.py

# Configure Looker models
vim looker/models/marketing_metrics.model.lkml
```

### 3. Deploy to Production
```bash
# Use the migration guide
cat docs/migration/production_migration_guide.md
```

## Common Use Cases

### 1. **Marketing Analytics**
- Campaign performance analysis
- Email marketing optimization
- Conversion rate tracking
- ROI measurement

### 2. **Data Quality Monitoring**
- Automated data validation
- Real-time quality alerts
- Data lineage tracking
- Compliance reporting

### 3. **Infrastructure Management**
- Kubernetes deployment
- Terraform provisioning
- Monitoring and alerting
- Security and compliance

## Troubleshooting

### Common Issues

**Docker Issues**
```bash
# Reset Docker environment
docker-compose down -v
docker system prune -a
docker-compose up -d
```

**DBT Connection Issues**
```bash
# Test Snowflake connection
cd dbt
dbt debug
```

**Airflow Issues**
```bash
# Check Airflow logs
docker-compose logs airflow-webserver
docker-compose logs airflow-scheduler
```

### Getting Help

1. **Check Logs**: `docker-compose logs -f`
2. **Review Documentation**: `docs/` directory
3. **Test Components**: Use debug commands
4. **Validate Configuration**: Check environment variables

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources  │    │   Orchestration │    │   Data Warehouse│
│                 │    │                 │    │                 │
│ • APIs          │───▶│   Apache        │───▶│   Snowflake     │
│ • Databases     │    │   Airflow       │    │                 │
│ • Files         │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Data          │
                       │   Transformation│
                       │                 │
                       │   DBT           │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Analytics &   │
                       │   Monitoring    │
                       │                 │
                       │ • Looker        │
                       │ • Grafana       │
                       │ • Prometheus    │
                       └─────────────────┘
```

## Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Local development environment |
| `dbt/dbt_project.yml` | DBT project configuration |
| `airflow/dags/` | Airflow workflow definitions |
| `snowflake/` | Snowflake schemas and permissions |
| `monitoring/` | Prometheus and Grafana configs |
| `looker/` | Looker models and dashboards |
| `cicd/` | CI/CD pipeline configurations |

## Support

- **Documentation**: Check `docs/` directory
- **Issues**: Review logs and configuration
- **Community**: Data engineering best practices
- **Updates**: Regular platform improvements

---

**Ready to build amazing data solutions?** 🚀

Start with the sample data pipeline and customize it for your needs!
