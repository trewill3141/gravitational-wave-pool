-- Analyst role configuration
-- Role for business analysts with read-only access to marts

CREATE ROLE IF NOT EXISTS analyst;

-- Grant warehouse usage (smaller warehouse for analysts)
GRANT USAGE ON WAREHOUSE analytics_warehouse TO ROLE analyst;

-- Grant database permissions
GRANT USAGE ON DATABASE gravitational_wave_pool TO ROLE analyst;

-- Grant schema permissions (read-only access to marts)
GRANT USAGE ON SCHEMA marts TO ROLE analyst;

-- Grant table permissions (read-only)
GRANT SELECT ON ALL TABLES IN SCHEMA marts TO ROLE analyst;

-- Grant future table permissions (read-only)
GRANT SELECT ON FUTURE TABLES IN SCHEMA marts TO ROLE analyst;

-- Grant view permissions (read-only)
GRANT SELECT ON ALL VIEWS IN SCHEMA marts TO ROLE analyst;

-- Grant future view permissions (read-only)
GRANT SELECT ON FUTURE VIEWS IN SCHEMA marts TO ROLE analyst;
