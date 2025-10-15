# Snowflake Configuration

This directory contains Snowflake configuration files for the data engineering prototyping environment.

## Directory Structure

```
snowflake/
├── schemas/           # Database schema definitions
├── warehouses/        # Warehouse configurations
├── roles/            # Role and permission definitions
└── README.md         # This file
```

## Schemas

### Raw Schema (`raw_schema.sql`)
- Contains raw, unprocessed data from source systems
- Used for initial data ingestion
- Minimal data cleaning or transformation

### Staging Schema (`staging_schema.sql`)
- Contains cleaned and standardized data
- Data is processed and ready for analytics
- Intermediate layer between raw and marts

### Marts Schema (`marts_schema.sql`)
- Contains business-ready dimensional models
- Final analytics tables for reporting
- Optimized for query performance

## Warehouses

### Development Warehouse (`development_warehouse.sql`)
- **Size**: X-SMALL
- **Auto-suspend**: 60 seconds
- **Purpose**: Development and testing
- **Cost**: Minimal

### Production Warehouse (`production_warehouse.sql`)
- **Size**: MEDIUM
- **Auto-suspend**: 300 seconds
- **Purpose**: Production workloads
- **Cost**: Moderate

### Analytics Warehouse (`analytics_warehouse.sql`)
- **Size**: LARGE
- **Auto-suspend**: 600 seconds
- **Purpose**: Reporting and dashboards
- **Cost**: Higher for performance

## Roles

### Data Engineer Role (`data_engineer_role.sql`)
- Full access to all schemas and warehouses
- Can create, modify, and delete tables
- Appropriate for development and production

### Analyst Role (`analyst_role.sql`)
- Read-only access to marts schema
- Uses analytics warehouse
- Appropriate for business analysts

### Read-only Role (`readonly_role.sql`)
- Minimal read-only access to marts schema
- Uses analytics warehouse
- Appropriate for external users

## Usage

### Setting Up Schemas
```sql
-- Run schema files in order
@raw_schema.sql
@staging_schema.sql
@marts_schema.sql
```

### Setting Up Warehouses
```sql
-- Create warehouses
@development_warehouse.sql
@production_warehouse.sql
@analytics_warehouse.sql
```

### Setting Up Roles
```sql
-- Create roles
@data_engineer_role.sql
@analyst_role.sql
@readonly_role.sql
```

## Best Practices

1. **Use Appropriate Warehouses**: Match warehouse size to workload
2. **Follow Schema Patterns**: Raw → Staging → Marts
3. **Principle of Least Privilege**: Grant minimal necessary permissions
4. **Monitor Costs**: Use auto-suspend to control costs
5. **Document Changes**: Update this README when adding new configurations

## Cost Optimization

- **Development**: Use X-SMALL warehouse with short auto-suspend
- **Production**: Use appropriately sized warehouse with longer auto-suspend
- **Analytics**: Use larger warehouse for complex queries, longer auto-suspend
- **Monitoring**: Set up alerts for warehouse usage and costs

## Security

- **Role-based Access**: Different roles for different user types
- **Schema Isolation**: Separate schemas for different data layers
- **Minimal Permissions**: Grant only necessary permissions
- **Regular Audits**: Review permissions periodically
