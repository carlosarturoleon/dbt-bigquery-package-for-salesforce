{{ config(materialized='view') }}

with source as (
    select * from {{ source('salesforce', 'salesforce_leads') }}
),

transformed as (
    select
        lead_id as id,
        lead_first_name as first_name,
        lead_last_name as last_name,
        lead_name as full_name,
        
        -- Handle email field with fallback
        coalesce(lead_email, email) as email,
        
        lead_company as company,
        lead_title as title,
        lead_phone as phone,
        lead_status as status,
        lead_lead_source as source,
        lead_rating as rating,
        
        -- Convert STRING date fields to proper types
        safe_cast(lead_created_date as timestamp) as created_at,
        
        -- Conversion tracking fields
        lead_converted_date as converted_date,
        lead_converted_contact_id as converted_contact_id,
        lead_converted_opportunity_id as converted_opportunity_id,
        lead_converted_account_id as converted_account_id,
        
        -- Convert string boolean to actual boolean
        safe_cast(lead_is_converted as boolean) as is_converted,
        
        -- Calculate days_to_conversion
        case 
            when safe_cast(lead_converted_date as date) is not null 
                and safe_cast(lead_created_date as timestamp) is not null
            then date_diff(
                safe_cast(lead_converted_date as date),
                date(safe_cast(lead_created_date as timestamp)),
                day
            )
            else null
        end as days_to_conversion,
        
        -- Address fields
        lead_street as street,
        lead_city as city,
        lead_state as state,
        lead_postal_code as postal_code,
        lead_country as country,
        
        -- Other useful fields
        lead_owner_id as owner_id,
        lead_industry as industry,
        lead_annual_revenue as annual_revenue,
        lead_number_of_employees as number_of_employees,
        

    from source
    where lower(lead_is_deleted) = 'false'
)

select * from transformed