-- Dimension table for users
-- This is a table that provides a business-friendly view of user data

with stg_users as (
    select * from {{ ref('stg_example') }}
),

dim_users as (
    select
        id as user_id,
        name as user_name,
        email_cleaned as email,
        status_normalized as status,
        created_at,
        updated_at,
        current_timestamp as dbt_updated_at
    from stg_users
)

select * from dim_users
