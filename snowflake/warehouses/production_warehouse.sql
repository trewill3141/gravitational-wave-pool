-- Production warehouse configuration
-- Larger warehouse for production workloads

CREATE WAREHOUSE IF NOT EXISTS production_warehouse
WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Production warehouse for data engineering workloads';

-- Grant usage to data engineering role
GRANT USAGE ON WAREHOUSE production_warehouse TO ROLE data_engineer;

-- Set warehouse properties
ALTER WAREHOUSE production_warehouse SET
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    COMMENT = 'Production warehouse for data engineering workloads';
