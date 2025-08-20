{{ config(materialized='view') }}

with source as (
    select * from {{ source('salesforce', 'salesforce_opportunities') }}
),

transformed as (
    select
        opportunity_id as id,
        opportunity_name as name,
        opportunity_description as description,
        opportunity_type as type,
        
        -- Links to primary campaign source via campaign_id
        opportunity_campaign_id as campaign_id,
        
        -- Account and contact associations
        opportunity_account_id as account_id,
        opportunity_contact_id as contact_id,
        
        -- Stage progression and win/loss status
        opportunity_stage_name as stage_name,
        opportunity_forecast_category as forecast_category,
        opportunity_forecast_category_name as forecast_category_name,
        
        -- Clean boolean conversions using SAFE_CAST
        safe_cast(opportunity_is_closed as boolean) as is_closed,
        safe_cast(opportunity_is_won as boolean) as is_won,
        
        -- Financial fields - includes expected_revenue and amount fields
        safe_cast(opportunity_amount as numeric) as amount,
        safe_cast(opportunity_probability as numeric) as probability,
        
        -- Calculate expected_revenue as amount * probability
        case 
            when safe_cast(opportunity_amount as numeric) is not null 
                and safe_cast(opportunity_probability as numeric) is not null
            then safe_cast(opportunity_amount as numeric) * (safe_cast(opportunity_probability as numeric) / 100)
            else null
        end as expected_revenue,
        
        -- Clean date conversions using SAFE_CAST
        coalesce(
            safe_cast(opportunity_created_date as timestamp),
            safe_cast(opportunity_createddate as timestamp)
        ) as created_at,
        
        safe_cast(opportunity_close_date as date) as close_date,
        
        coalesce(
            safe_cast(opportunity_last_modified_date as timestamp),
            safe_cast(opportunity_lastmodifieddate as timestamp)
        ) as last_modified_at,
        
        safe_cast(opportunity_last_activity_date as date) as last_activity_date,
        safe_cast(opportunity_last_referenced_date as timestamp) as last_referenced_at,
        safe_cast(opportunity_last_viewed_date as timestamp) as last_viewed_at,
        
        -- Calculate sales_cycle_days using SAFE_CAST
        case 
            when safe_cast(opportunity_close_date as date) is not null
                and coalesce(
                    safe_cast(opportunity_created_date as timestamp),
                    safe_cast(opportunity_createddate as timestamp)
                ) is not null
            then date_diff(
                safe_cast(opportunity_close_date as date),
                date(coalesce(
                    safe_cast(opportunity_created_date as timestamp),
                    safe_cast(opportunity_createddate as timestamp)
                )),
                day
            )
            else null
        end as sales_cycle_days,
        
        -- Fiscal period fields
        opportunity_fiscal as fiscal_period,
        safe_cast(opportunity_fiscal_quarter as integer) as fiscal_quarter,
        safe_cast(opportunity_fiscal_year as integer) as fiscal_year,
        
        -- Activity tracking - clean boolean conversions
        safe_cast(opportunity_has_open_activity as boolean) as has_open_activity,
        safe_cast(opportunity_has_opportunity_line_item as boolean) as has_opportunity_line_item,
        safe_cast(opportunity_has_overdue_task as boolean) as has_overdue_task,
        
        -- Lead source
        opportunity_lead_source as lead_source,
        
        -- Process fields
        opportunity_next_step as next_step,
        
        -- Owner and system fields
        opportunity_owner_id as owner_id,
        opportunity_created_by_id as created_by_id,
        opportunity_last_modified_by_id as last_modified_by_id,
        opportunity_pricebook2_id as pricebook_id,
        opportunity_system_modstamp as system_modstamp,
        
        -- History tracking
        opportunity_last_amount_changed_history_id as last_amount_changed_history_id,
        opportunity_last_close_date_changed_history_id as last_close_date_changed_history_id,
        
        -- Custom fields
        opportunity_wsai__currentgenerators__c as current_generators,
        opportunity_wsai__deliveryinstallationstatus__c as delivery_installation_status,
        opportunity_wsai__maincompetitors__c as main_competitors,
        opportunity_wsai__ordernumber__c as order_number,
        opportunity_wsai__trackingnumber__c as tracking_number

    from source
    where opportunity_is_deleted = 'false'
)

select * from transformed