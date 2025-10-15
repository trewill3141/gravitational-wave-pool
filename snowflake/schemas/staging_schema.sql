-- Staging schema for cleaned and standardized data
-- This schema contains processed data ready for analytics

CREATE SCHEMA IF NOT EXISTS staging;

-- Grant permissions
GRANT USAGE ON SCHEMA staging TO ROLE data_engineer;
GRANT CREATE TABLE ON SCHEMA staging TO ROLE data_engineer;
GRANT CREATE VIEW ON SCHEMA staging TO ROLE data_engineer;

-- Example staging table
CREATE OR REPLACE TABLE staging.events_cleaned (
    event_timestamp TIMESTAMP_NTZ,
    channel_key VARCHAR(50),
    campaign_key VARCHAR(100),
    metric_name VARCHAR(100),
    email_send INTEGER,
    text_send INTEGER,
    email_open INTEGER,
    applications_submitted INTEGER,
    email_cleaned VARCHAR(255),
    status_normalized VARCHAR(20),
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
);

-- Grant permissions on tables
GRANT SELECT ON TABLE staging.events_cleaned TO ROLE data_engineer;
GRANT INSERT ON TABLE staging.events_cleaned TO ROLE data_engineer;
GRANT UPDATE ON TABLE staging.events_cleaned TO ROLE data_engineer;
