{{ config(materialized='view') }}

with source as (
    select * from {{ source('salesforce', 'salesforce_campaigns') }}
),

transformed as (
    select
        campaign_id as id,
        campaign_name as name,
        campaign_type as type,
        campaign_status as status,
        
        campaign_description as description,
        
        -- Convert STRING date fields to proper types
        case 
            when campaign_created_date is not null and campaign_created_date != ''
            then parse_timestamp('%Y-%m-%d %H:%M:%S', campaign_created_date)
            else null
        end as created_at,
        
        case 
            when campaign_start_date is not null and campaign_start_date != ''
            then parse_date('%Y-%m-%d', campaign_start_date)
            else null
        end as start_date,
        
        case 
            when campaign_end_date is not null and campaign_end_date != ''
            then parse_date('%Y-%m-%d', campaign_end_date)
            else null
        end as end_date,
        
        -- Convert string boolean to actual boolean
        case 
            when lower(campaign_is_active) = 'true' then true
            when lower(campaign_is_active) = 'false' then false
            else null
        end as is_active,
        
        -- Cast numeric fields appropriately
        safe_cast(campaign_actual_cost as numeric) as actual_cost,
        safe_cast(campaign_budgeted_cost as numeric) as budgeted_cost,
        safe_cast(campaign_expected_revenue as numeric) as expected_revenue,
        safe_cast(campaign_expected_response as numeric) as expected_response,
        safe_cast(campaign_number_sent as numeric) as number_sent,
        
        -- Calculate campaign duration in days
        case 
            when campaign_start_date is not null and campaign_start_date != ''
                and campaign_end_date is not null and campaign_end_date != ''
            then date_diff(
                parse_date('%Y-%m-%d', campaign_end_date),
                parse_date('%Y-%m-%d', campaign_start_date),
                day
            )
            else null
        end as campaign_duration_days,
        
        -- Aggregated fields
        safe_cast(campaign_number_of_leads as numeric) as number_of_leads,
        safe_cast(campaign_number_of_converted_leads as numeric) as number_of_converted_leads,
        safe_cast(campaign_number_of_contacts as numeric) as number_of_contacts,
        safe_cast(campaign_number_of_opportunities as numeric) as number_of_opportunities,
        safe_cast(campaign_number_of_won_opportunities as numeric) as number_of_won_opportunities,
        safe_cast(campaign_amount_all_opportunities as numeric) as amount_all_opportunities,
        safe_cast(campaign_amount_won_opportunities as numeric) as amount_won_opportunities,
        
        -- Include other useful fields
        campaign_owner_id as owner_id,
        campaign_parent_id as parent_id,

    from source
    where campaign_is_deleted = 'false'
)

select * from transformed