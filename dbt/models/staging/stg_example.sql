-- Staging model for example data
-- This is a view that cleans and standardizes raw data

with source_data as (
    select * from {{ source('raw', 'example_table') }}
),

cleaned_data as (
    select
        id,
        name,
        email,
        created_at,
        updated_at,
        -- Add any data cleaning logic here
        trim(lower(email)) as email_cleaned,
        case 
            when status = 'active' then 'ACTIVE'
            when status = 'inactive' then 'INACTIVE'
            else 'UNKNOWN'
        end as status_normalized
    from source_data
)

select * from cleaned_data
