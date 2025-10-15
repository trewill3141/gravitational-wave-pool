-- Analytics warehouse configuration
-- Optimized for analytical workloads and reporting

CREATE WAREHOUSE IF NOT EXISTS analytics_warehouse
WITH
    WAREHOUSE_SIZE = 'LARGE'
    AUTO_SUSPEND = 600
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Analytics warehouse for reporting and dashboards';

-- Grant usage to data engineering role
GRANT USAGE ON WAREHOUSE analytics_warehouse TO ROLE data_engineer;

-- Set warehouse properties
ALTER WAREHOUSE analytics_warehouse SET
    WAREHOUSE_SIZE = 'LARGE'
    AUTO_SUSPEND = 600
    AUTO_RESUME = TRUE
    COMMENT = 'Analytics warehouse for reporting and dashboards';
