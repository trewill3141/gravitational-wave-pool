-- Data Engineer role configuration
-- Role for data engineering team with appropriate permissions

CREATE ROLE IF NOT EXISTS data_engineer;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE development_warehouse TO ROLE data_engineer;
GRANT USAGE ON WAREHOUSE production_warehouse TO ROLE data_engineer;
GRANT USAGE ON WAREHOUSE analytics_warehouse TO ROLE data_engineer;

-- Grant database permissions
GRANT USAGE ON DATABASE gravitational_wave_pool TO ROLE data_engineer;
GRANT CREATE SCHEMA ON DATABASE gravitational_wave_pool TO ROLE data_engineer;

-- Grant schema permissions
GRANT USAGE ON SCHEMA raw TO ROLE data_engineer;
GRANT USAGE ON SCHEMA staging TO ROLE data_engineer;
GRANT USAGE ON SCHEMA marts TO ROLE data_engineer;

-- Grant table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA raw TO ROLE data_engineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA staging TO ROLE data_engineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA marts TO ROLE data_engineer;

-- Grant future permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA raw TO ROLE data_engineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA staging TO ROLE data_engineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA marts TO ROLE data_engineer;

-- Grant view permissions
GRANT SELECT ON ALL VIEWS IN SCHEMA raw TO ROLE data_engineer;
GRANT SELECT ON ALL VIEWS IN SCHEMA staging TO ROLE data_engineer;
GRANT SELECT ON ALL VIEWS IN SCHEMA marts TO ROLE data_engineer;

-- Grant future view permissions
GRANT SELECT ON FUTURE VIEWS IN SCHEMA raw TO ROLE data_engineer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA staging TO ROLE data_engineer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA marts TO ROLE data_engineer;
