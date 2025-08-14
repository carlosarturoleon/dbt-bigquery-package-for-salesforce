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
        case 
            when lead_created_date is not null and lead_created_date != ''
            then parse_timestamp('%Y-%m-%d %H:%M:%S', lead_created_date)
            else null
        end as created_at,
        
        -- Conversion tracking fields
        lead_converted_date as converted_date,
        lead_converted_contact_id as converted_contact_id,
        lead_converted_opportunity_id as converted_opportunity_id,
        lead_converted_account_id as converted_account_id,
        
        -- Convert string boolean to actual boolean
        case 
            when lower(lead_is_converted) = 'true' then true
            when lower(lead_is_converted) = 'false' then false
            else null
        end as is_converted,
        
        -- Calculate days_to_conversion
        case 
            when lead_converted_date is not null 
                and lead_created_date is not null and lead_created_date != ''
            then date_diff(
                date(lead_converted_date),
                date(parse_timestamp('%Y-%m-%d %H:%M:%S', lead_created_date)),
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
    where lead_is_deleted = 'false'
)

select * from transformed