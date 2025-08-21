# dbt Salesforce Campaign Funnel Package

Production-ready dbt package that transforms raw Salesforce data into clean, analytics-ready tables modeling the complete Campaign → Lead → Contact → Campaign Member → Opportunity funnel.

## 📊 What This Package Does

Transforms Salesforce data into comprehensive funnel analytics with:
- Campaign ROI and performance metrics
- Lead conversion tracking with timing
- Stage-by-stage funnel visualization
- Multi-touch attribution analysis
- Executive dashboard compatibility

## 🎯 Models Included

### Staging Models (`stg_salesforce__*`)
- Clean and standardize raw Salesforce data
- Handle data types, naming, and basic filtering

### Intermediate Models (`int_salesforce__*`) 
- Business logic and metric calculations
- Lead journey tracking and attribution
- Campaign performance aggregations

### Marts Models (`salesforce__*`)
- Final analytics-ready tables
- Executive dashboard compatibility
- BigQuery optimized with partitioning/clustering

## 📋 Requirements

- dbt Core >= 1.0.0
- BigQuery (currently supported data warehouse)
- Salesforce source data tables

## 🚀 Quick Start

1. Add to your `packages.yml`:
```yaml
packages:
  - git: "https://github.com/carlosarturoleon/dbt-salesforce-campaign-funnel.git"
    revision: main
```

2. Run `dbt deps`

3. Configure your `sources.yml` with your Salesforce tables

4. Run `dbt run`

## ⚙️ Configuration

### Source Tables Required

Define these source tables in your `sources.yml`:

```yaml
sources:
  - name: salesforce
    tables:
      - name: campaigns
      - name: leads  
      - name: contacts
      - name: campaign_members
      - name: opportunities
```

### Field Mapping Configuration

The package uses configurable field mappings to work with different Salesforce org schemas. Override these variables in your `dbt_project.yml`:

```yaml
vars:
  # Example: Custom field names for campaigns
  campaigns_id_field: 'id'
  campaigns_name_field: 'name' 
  campaigns_type_field: 'type'
  
  # Example: Custom picklist values
  salesforce_campaign_types:
    - 'Email'
    - 'Social Media'
    - 'Custom Type'
```

Available field mapping variables include:
- `campaigns_*_field` - Campaign table field mappings
- `leads_*_field` - Lead table field mappings  
- `contacts_*_field` - Contact table field mappings
- `campaign_members_*_field` - Campaign member table field mappings
- `opportunities_*_field` - Opportunity table field mappings

### Picklist Value Configuration

Configure picklist values to match your Salesforce org:
- `salesforce_campaign_types`
- `salesforce_campaign_statuses`
- `salesforce_lead_statuses`
- `salesforce_opportunity_stages`
- `salesforce_campaign_member_statuses`

## 🔧 Utility Macros

The package includes utility macros for common data transformations:

- `clean_boolean()` - Convert string booleans to proper boolean type
- `clean_email()` - Clean and validate email addresses
- `safe_date_parse()` - Robust date parsing with error handling
- `calculate_days_between()` - Calculate days between two dates
- `clean_currency()` - Clean numeric/currency fields with validation
- `clean_phone()` - Standardize phone number formats
- `parse_date_with_format()` - Parse dates with specific formats
- `coalesce_email_fields()` - Handle multiple email field variations

## 📊 Output Models

### Staging Models
- `stg_salesforce__campaigns` - Cleaned campaign data
- `stg_salesforce__leads` - Cleaned lead data
- `stg_salesforce__contacts` - Cleaned contact data
- `stg_salesforce__campaign_members` - Cleaned campaign member data
- `stg_salesforce__opportunities` - Cleaned opportunity data

### Intermediate Models
- `int_salesforce__lead_journey` - Lead progression tracking
- `int_salesforce__campaign_performance` - Campaign metrics
- `int_salesforce__contact_touchpoints` - Contact interaction history

### Marts Models
- `salesforce__campaign_lead_funnel` - Complete funnel analysis
- `salesforce__campaign_attribution_summary` - Attribution reporting

## 🧪 Data Quality Tests

The package includes tests for:
- Field uniqueness and not-null constraints
- Referential integrity between tables
- Picklist value validation
- Date range validation
- Email format validation

## 📈 Use Cases

Perfect for:
- Marketing attribution analysis
- Lead conversion optimization
- Campaign ROI measurement
- Sales funnel reporting
- Executive dashboards