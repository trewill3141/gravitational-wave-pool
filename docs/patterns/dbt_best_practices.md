# DBT Best Practices

## Model Organization

### Layered Architecture
```
raw/           # Source data (external)
├── staging/   # Cleaned and standardized data
├── marts/     # Business-ready dimensional models
└── utils/     # Utility models and macros
```

### Naming Conventions
- **Staging models**: `stg_` prefix (e.g., `stg_users`)
- **Mart models**: `dim_` for dimensions, `fct_` for facts
- **Utility models**: `int_` for intermediate models
- **Snapshots**: `snap_` prefix

## Model Design

### Staging Models
```sql
-- stg_users.sql
with source_data as (
    select * from {{ source('raw', 'users') }}
),

cleaned_data as (
    select
        id,
        trim(lower(email)) as email,
        created_at,
        updated_at
    from source_data
)

select * from cleaned_data
```

### Mart Models
```sql
-- dim_users.sql
with stg_users as (
    select * from {{ ref('stg_users') }}
),

dim_users as (
    select
        id as user_id,
        email,
        created_at,
        updated_at,
        current_timestamp as dbt_updated_at
    from stg_users
)

select * from dim_users
```

## Testing Strategy

### Source Tests
```yaml
# sources.yml
sources:
  - name: raw
    tables:
      - name: users
        columns:
          - name: id
            tests:
              - unique
              - not_null
          - name: email
            tests:
              - not_null
```

### Model Tests
```yaml
# models.yml
models:
  - name: dim_users
    columns:
      - name: user_id
        tests:
          - unique
          - not_null
      - name: email
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "email like '%@%'"
```

## Macros

### Reusable Macros
```sql
-- macros/get_columns.sql
{% macro get_columns(table_name) %}
    {% set query %}
        select column_name
        from information_schema.columns
        where table_name = '{{ table_name }}'
    {% endset %}
    
    {% set results = run_query(query) %}
    {% if execute %}
        {{ return(results.columns[0].values()) }}
    {% endif %}
{% endmacro %}
```

## Documentation

### Model Documentation
```yaml
# models.yml
models:
  - name: dim_users
    description: "User dimension table with cleaned user data"
    columns:
      - name: user_id
        description: "Unique identifier for the user"
        tests:
          - unique
          - not_null
```

### Source Documentation
```yaml
# sources.yml
sources:
  - name: raw
    description: "Raw data from source systems"
    tables:
      - name: users
        description: "User data from the main application"
```

## Performance Optimization

### Incremental Models
```sql
-- fct_orders_incremental.sql
{{
  config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='fail'
  )
}}

select * from {{ ref('stg_orders') }}

{% if is_incremental() %}
  where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

### Clustering
```sql
-- models/schema.yml
models:
  - name: fct_orders
    config:
      cluster_by: ['order_date', 'customer_id']
```

## Environment Management

### Profiles
```yaml
# profiles.yml
gravitational_wave_pool:
  target: dev
  outputs:
    dev:
      type: snowflake
      # ... dev config
    prod:
      type: snowflake
      # ... prod config
```

### Variables
```yaml
# dbt_project.yml
vars:
  start_date: '2020-01-01'
  end_date: '2024-12-31'
```

## Data Quality

### Custom Tests
```sql
-- tests/custom_tests.sql
-- Test that all users have valid emails
select *
from {{ ref('dim_users') }}
where email not like '%@%'
```

### Freshness Tests
```yaml
# sources.yml
sources:
  - name: raw
    tables:
      - name: users
        loaded_at_field: updated_at
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 24, period: hour}
```
