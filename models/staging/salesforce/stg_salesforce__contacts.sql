{{ config(materialized='view') }}

with source as (
    select * from {{ source('salesforce', 'salesforce_contacts') }}
),

transformed as (
    select
        contact_id as id,
        contact_firstname as first_name,
        contact_lastname as last_name,
        contact_name as full_name,
        contact_salutation as salutation,
        
        contact_email as email,
        contact_phone as phone,
        contact_mobilephone as mobile_phone,
        contact_homephone as home_phone,
        contact_otherphone as other_phone,
        contact_fax as fax,
        
        contact_title as title,
        contact_department as department,
        contact_leadsource as lead_source,
        contact_description as description,
        
        -- Clean date conversions using SAFE_CAST
        safe_cast(contact_createddate as timestamp) as created_at,
        safe_cast(contact_lastmodifieddate as timestamp) as last_modified_at,
        safe_cast(contact_birthdate as date) as birthdate,
        safe_cast(contact_lastactivitydate as date) as last_activity_date,
        safe_cast(contact_lastreferenceddatetime as timestamp) as last_referenced_at,
        safe_cast(contact_lastvieweddate as timestamp) as last_viewed_at,
        safe_cast(contact_emailbounceddate as timestamp) as email_bounced_at,
        
        -- Account association
        contact_accountid as account_id,
        
        -- Clean boolean conversion
        safe_cast(contact_isemailbounced as boolean) as is_email_bounced,
        contact_emailbouncedreason as email_bounced_reason,
        
        -- Mailing address fields
        contact_mailingstreet as mailing_street,
        contact_mailingcity as mailing_city,
        contact_mailingstate as mailing_state,
        contact_mailingpostalcode as mailing_postal_code,
        contact_mailingcountry as mailing_country,
        
        -- Other address fields
        contact_otherstreet as other_street,
        contact_othercity as other_city,
        contact_otherstate as other_state,
        contact_otherpostalcode as other_postal_code,
        contact_othercountry as other_country,
        
        -- Other useful fields
        contact_ownerid as owner_id,
        contact_reportstoid as reports_to_id,
        contact_assistantname as assistant_name,
        contact_assistantphone as assistant_phone,
        contact_createdby as created_by,
        
        -- Custom fields
        contact_wsai__languages__c as languages,
        contact_wsai__level__c as level,
        
        -- System field
        contact_date as date_field
        
    from source
    where lower(contact_isdeleted) = 'false'
)

select * from transformed