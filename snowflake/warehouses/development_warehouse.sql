-- Development warehouse configuration
-- Small warehouse for development and testing

CREATE WAREHOUSE IF NOT EXISTS development_warehouse
WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Development warehouse for data engineering prototyping';

-- Grant usage to data engineering role
GRANT USAGE ON WAREHOUSE development_warehouse TO ROLE data_engineer;

-- Set warehouse properties
ALTER WAREHOUSE development_warehouse SET
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'Development warehouse for data engineering prototyping';
