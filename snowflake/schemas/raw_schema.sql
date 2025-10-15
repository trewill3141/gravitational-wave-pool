-- Raw data schema for staging external data
-- This schema contains raw, unprocessed data from source systems

CREATE SCHEMA IF NOT EXISTS raw;

-- Grant permissions
GRANT USAGE ON SCHEMA raw TO ROLE data_engineer;
GRANT CREATE TABLE ON SCHEMA raw TO ROLE data_engineer;
GRANT CREATE VIEW ON SCHEMA raw TO ROLE data_engineer;

-- Example table for raw event data
CREATE OR REPLACE TABLE raw.events (
    event_timestamp TIMESTAMP_NTZ,
    channel_key VARCHAR(50),
    campaign_key VARCHAR(100),
    metric_name VARCHAR(100),
    email_send INTEGER DEFAULT 0,
    text_send INTEGER DEFAULT 0,
    email_open INTEGER DEFAULT 0,
    applications_submitted INTEGER DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Grant permissions on tables
GRANT SELECT ON TABLE raw.events TO ROLE data_engineer;
GRANT INSERT ON TABLE raw.events TO ROLE data_engineer;
GRANT UPDATE ON TABLE raw.events TO ROLE data_engineer;
