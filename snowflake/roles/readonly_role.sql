-- Read-only role configuration
-- Role for external users with minimal read-only access

CREATE ROLE IF NOT EXISTS readonly;

-- Grant warehouse usage (smallest warehouse)
GRANT USAGE ON WAREHOUSE analytics_warehouse TO ROLE readonly;

-- Grant database permissions
GRANT USAGE ON DATABASE gravitational_wave_pool TO ROLE readonly;

-- Grant schema permissions (read-only access to marts only)
GRANT USAGE ON SCHEMA marts TO ROLE readonly;

-- Grant table permissions (read-only)
GRANT SELECT ON ALL TABLES IN SCHEMA marts TO ROLE readonly;

-- Grant future table permissions (read-only)
GRANT SELECT ON FUTURE TABLES IN SCHEMA marts TO ROLE readonly;

-- Grant view permissions (read-only)
GRANT SELECT ON ALL VIEWS IN SCHEMA marts TO ROLE readonly;

-- Grant future view permissions (read-only)
GRANT SELECT ON FUTURE VIEWS IN SCHEMA marts TO ROLE readonly;
