-- Marts schema for business-ready dimensional models
-- This schema contains final analytics tables for reporting

CREATE SCHEMA IF NOT EXISTS marts;

-- Grant permissions
GRANT USAGE ON SCHEMA marts TO ROLE data_engineer;
GRANT CREATE TABLE ON SCHEMA marts TO ROLE data_engineer;
GRANT CREATE VIEW ON SCHEMA marts TO ROLE data_engineer;

-- Example mart tables
CREATE OR REPLACE TABLE marts.dim_users (
    user_id VARCHAR(50),
    user_name VARCHAR(255),
    email VARCHAR(255),
    status VARCHAR(20),
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ,
    dbt_updated_at TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE marts.fct_metric_analysis_daily (
    date DATE,
    channel VARCHAR(50),
    campaign VARCHAR(100),
    metric VARCHAR(100),
    total INTEGER,
    n_time_period_average FLOAT,
    comparison FLOAT,
    performance_category VARCHAR(20),
    performance_color VARCHAR(10)
);

-- Grant permissions on tables
GRANT SELECT ON TABLE marts.dim_users TO ROLE data_engineer;
GRANT SELECT ON TABLE marts.fct_metric_analysis_daily TO ROLE data_engineer;
