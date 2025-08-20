{{ config(materialized='view') }}

with source as (
    select * from {{ source('salesforce', 'salesforce_campaign_members') }}
),

transformed as (
    select
        campaignmember_id as id,
        campaignmember_campaign_id as campaign_id,
        campaignmember_lead_id as lead_id,
        campaignmember_contact_id as contact_id,
        campaignmember_lead_or_contact_id as lead_or_contact_id,
        
        -- Determine member_type as 'Lead' or 'Contact' based on which ID is populated
        case 
            when campaignmember_lead_id is not null then 'Lead'
            when campaignmember_contact_id is not null then 'Contact'
            else campaignmember_type
        end as member_type,
        
        campaignmember_first_name as first_name,
        campaignmember_last_name as last_name,
        campaignmember_name as full_name,
        campaignmember_salutation as salutation,
        
        campaignmember_company_or_account as company_or_account,
        campaignmember_title as title,
        campaignmember_phone as phone,
        campaignmember_fax as fax,
        campaignmember_lead_source as lead_source,
        campaignmember_description as description,
        
        -- Date fields (already TIMESTAMP in source)
        campaignmember_createddate as created_at,
        campaignmember_lastmodifieddate as last_modified_at,
        campaignmember_first_responded_date as first_responded_date,
        
        -- Convert string boolean to actual boolean for response tracking
        case 
            when lower(campaignmember_has_responded) = 'true' then true
            when lower(campaignmember_has_responded) = 'false' then false
            else null
        end as has_responded,
        
        campaignmember_status as status,
        
        -- Calculate days_to_response from campaign member creation to response
        case 
            when campaignmember_first_responded_date is not null 
                and campaignmember_createddate is not null
            then date_diff(
                date(campaignmember_first_responded_date),
                date(campaignmember_createddate),
                day
            )
            else null
        end as days_to_response,
        
        -- Address fields
        campaignmember_street as street,
        campaignmember_postal_code as postal_code,
        campaignmember_state as state,
        campaignmember_country as country,
        
        -- Convert string boolean fields
        case 
            when lower(campaignmember_do_not_call) = 'true' then true
            when lower(campaignmember_do_not_call) = 'false' then false
            else null
        end as do_not_call,
        
        case 
            when lower(campaignmember_has_opted_out_of_fax) = 'true' then true
            when lower(campaignmember_has_opted_out_of_fax) = 'false' then false
            else null
        end as has_opted_out_of_fax,
        
        -- Owner tracking
        campaignmember_lead_or_contact_owner_id as lead_or_contact_owner_id

    from source
)

select * from transformed