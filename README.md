# dbt-BigQuery Package for Salesforce Campaign Funnel Data

A production-ready dbt package that transforms raw Salesforce data integrated with [Windsor.ai](https://windsor.ai/) into clean, analytics ready tables in BigQuery following standardized architecture patterns.

You can find a complete list of [available Salesforce fields here](https://windsor.ai/data-field/salesforce/).


## 🚀 Features of this dbt package:

- **Multi level data modeling**: Structured models for campaigns, leads, contacts, and opportunities
- **Campaign funnel analytics**: Complete lead → contact → opportunity attribution tracking
- **Business KPIs out of the box**: Pre-calculated metrics like conversion rates, campaign ROI, and lead progression timing
- **Reusable macros**: Modular macros for consistent metric calculation and data transformation
- **Custom tests**: Built in tests to ensure data quality and prevent duplicates
- **Type safety**: Safe and consistent casting of strings to numeric types using safe_cast
- **Performance optimized**: Designed for BigQuery efficiency with native data types and filter logic
- **Built for Windsor.ai**: Tailored to Windsor.ai's Salesforce schema and sync behavior
- **Executive dashboards**: Ready-to-use models for business intelligence

## What does this dbt package do?

This package transforms raw Salesforce data into clean, analytics ready tables modeling the complete **Campaign → Lead → Contact → Campaign Member → Opportunity** funnel. It provides:

- **Campaign ROI analysis**: Track performance metrics across campaigns
- **Lead conversion tracking**: Monitor progression with timing analytics  
- **Multi touch attribution**: Understand campaign touchpoint impact
- **Executive dashboards**: Ready to use models for business intelligence
- **Data quality assurance**: Built in validation and testing

## ⚙️ Prerequisites:

Before using this package, you have to integrate Salesforce data into BigQuery using the [Windsor.ai connector](https://windsor.ai/connect/salesforce-google-bigquery-integration/) to ensure the schema matches the expected format:

1. [Sign up](https://onboard.windsor.ai/) for Windsor.ai's free trial.
2. Connect your Salesforce account(s).
3. Choose BigQuery as a data destination.
4. Create and run a destination task for each of the 5 required tables by selecting specific fields. You can use the Report Presets dropdown to automatically select the necessary fields for each model (campaigns, leads, contacts, campaign_members, opportunities).

![Report Presets Example](analysis/docs/windsor_report_presets.png)

## ✅ Required BigQuery tables

These tables must be created with the field structure defined in the sources.yml file:

**campaigns**
- Campaign-level info such as names, types, status, and budgets
- Key fields: id, name, type, status, start_date, end_date, budgeted_cost, actual_cost, is_active

**leads**
- Lead records with contact information and source tracking
- Key fields: id, email, first_name, last_name, company, status, lead_source, created_date, converted_date, converted_contact_id, converted_opportunity_id

**contacts**
- Contact master data with account relationships
- Key fields: id, email, first_name, last_name, account_id, created_date, lead_source

**campaign_members**
- Campaign membership associations linking campaigns to leads/contacts
- Key fields: id, campaign_id, lead_id, contact_id, status, first_responded_date, created_date

**opportunities**
- Sales opportunity pipeline data with campaign attribution
- Key fields: id, name, account_id, amount, stage_name, close_date, campaign_id, created_date, is_closed, is_won

Windsor.ai will stream your Salesforce data to your BigQuery project in minutes. After verifying that the data is present, you're ready to start transforming it using this dbt package.

## 📋 Requirements

### Software versions
- **dbt Core** >= 1.0.0 (tested up to 1.8.x)
- **Python** >= 3.7 (required for dbt Core)

### Supported data warehouses
- **BigQuery** (primary support) - All features tested and optimized

### Data prerequisites
- **Salesforce source data** synced to your data warehouse via [Windsor.ai](https://windsor.ai/)
- **Source tables** available in your BigQuery project with the following requirements:

| **Table** | **Status** | **Description** | **Key Fields** |
|-----------|------------|-----------------|----------------|
| `campaigns` | **Required** | Campaign master data | `id`, `name`, `type`, `status`, `start_date`, `end_date` |
| `leads` | **Required** | Lead records and conversion tracking | `id`, `email`, `status`, `created_date`, `converted_date` |
| `contacts` | **Required** | Contact master data | `id`, `email`, `account_id`, `created_date` |
| `campaign_members` | **Required** | Campaign-lead/contact associations | `id`, `campaign_id`, `lead_id`, `contact_id` |
| `opportunities` | **Required** | Sales pipeline and revenue data | `id`, `name`, `amount`, `stage_name`, `close_date` |

## 🚀 Quick start

### Step 1: install the package

Add to your `packages.yml`:

```

packages:

- git: "https://github.com/carlosarturoleon/dbt-salesforce-campaign-funnel.git"
revision: main

```

### Step 2: install dependencies

```

dbt deps

```

### Step 3: configure source tables

Define your Salesforce source tables in `models/sources.yml`:

```

version: 2

sources:

- name: salesforce
description: "Raw Salesforce data tables"
tables:
    - name: campaigns
description: "Salesforce campaigns data"
    - name: leads
description: "Salesforce leads data"
    - name: contacts
description: "Salesforce contacts data"
    - name: campaign_members
description: "Campaign member associations"
    - name: opportunities
description: "Sales opportunities data"

```

### Step 4: run the models

```


# Run all models

dbt run

# Run specific layers

dbt run --select +stg_salesforce    \# Staging only
dbt run --select +int_salesforce    \# Staging + Intermediate
dbt run --select +salesforce        \# All models

# Run tests

dbt test

```

## 🏗️ Package architecture

This package follows dbt best practices with a threenlayer architecture for scalable, maintainable data transformations:

### **Staging models** (`stg_salesforce__*`)
*Purpose*: Clean and standardize raw Salesforce data from Windsor.ai integration

**Transformations applied:**
- Data type standardization and safe casting
- Consistent field naming conventions
- Basic data validation and quality checks
- Null value handling and default assignments
- Deduplication where necessary

**Models in this layer:**
- `stg_salesforce__campaigns` - Campaign master data
- `stg_salesforce__leads` - Lead information and status
- `stg_salesforce__contacts` - Contact details and account relationships
- `stg_salesforce__campaign_members` - Campaign membership associations
- `stg_salesforce__opportunities` - Sales opportunity pipeline data

### **Intermediate models** (`int_salesforce__*`)  
*Purpose*: Business logic, calculations, and relationship modeling

**Transformations applied:**
- Lead journey progression tracking with timing analysis
- Campaign performance metric calculations
- Multi touch attribution logic implementation
- Conversion funnel analysis
- Historical trend calculations

**Models in this layer:**
- `int_salesforce__lead_journey` - Lead lifecycle and conversion tracking
- `int_salesforce__campaign_performance` - Campaign metrics and ROI calculations
- `int_salesforce__contact_touchpoints` - Multi touch interaction history

### **Marts models** (`salesforce__*`)
*Purpose*: Analytics ready tables optimized for business intelligence and reporting

**Optimizations:**
- BigQuery partitioning and clustering for query performance
- Executive dashboard ready data structures
- Pre-calculated KPIs and business metrics
- Dimensional modeling for BI tool consumption

**Models in this layer:**
- `salesforce__campaign_lead_funnel` - Complete funnel analysis with conversion metrics
- `salesforce__campaign_attribution_summary` - Multi touch attribution reporting

## 📊 Models reference

| **Model** | **Layer** | **Description** | **Grain** |
|-----------|-----------|-----------------|-----------|
| `stg_salesforce__campaigns` | Staging | Cleaned and standardized campaign master data with consistent field naming and data types | One row per campaign |
| `stg_salesforce__leads` | Staging | Standardized lead information with safe casting and null handling | One row per lead |
| `stg_salesforce__contacts` | Staging | Clean contact records with account relationships and contact details | One row per contact |
| `stg_salesforce__campaign_members` | Staging | Campaign membership associations linking campaigns to leads/contacts | One row per campaign member |
| `stg_salesforce__opportunities` | Staging | Opportunity pipeline data with stage information and amounts | One row per opportunity |
| `int_salesforce__lead_journey` | Intermediate | Lead progression tracking with conversion timing and status changes | One row per lead with journey metrics |
| `int_salesforce__campaign_performance` | Intermediate | Campaign performance metrics including costs, responses, and conversion rates | One row per campaign with aggregated metrics |
| `int_salesforce__contact_touchpoints` | Intermediate | Contact interaction history across all campaigns and touchpoints | One row per contact-campaign interaction |
| `salesforce__campaign_lead_funnel` | Marts | **Complete funnel analysis** from campaigns through leads to opportunities with conversion metrics | One row per campaign with full funnel data |
| `salesforce__campaign_attribution_summary` | Marts | **Multi touch attribution reporting** showing campaign influence on pipeline and revenue | One row per campaign with attribution metrics |

## 🛠 How to use this dbt package

### Configure your dbt_project.yml:
```yaml
vars:  
  # Date range for processing (adjust as needed)
  start_date: '2020-01-01'
  end_date: '2024-12-31'
  
  # Currency settings
  target_currency: 'USD'
  
  # Data quality filters
  exclude_test_campaigns: true
  exclude_deleted_records: true
```

Make sure these source tables are available in your BigQuery project:
- campaigns
- leads
- contacts
- campaign_members
- opportunities

Run the models:
```bash
# Run all models  
dbt run

# Run specific layers  
dbt run --select +stg_salesforce    # Staging only  
dbt run --select +int_salesforce    # Staging + Intermediate  
dbt run --select +salesforce        # All models

# Run tests  
dbt test
```

## ⚙️ Configuration options

### Database and schema configuration

Configure database, schema, and source settings in your `dbt_project.yml`:

```yaml
# Configure the package
models:
  salesforce_campaign_funnel:
    +materialized: view
    +schema: salesforce
    staging:
      +schema: staging_salesforce
      +materialized: view
    intermediate:
      +schema: intermediate_salesforce
      +materialized: view
    marts:
      +schema: marts_salesforce
      +materialized: table
      +partition_by:
        field: created_date
        data_type: date
      +cluster_by: ["campaign_type", "status"]

# Source configuration
vars:
  # Source database and schema
  salesforce_database: "{{ target.database }}"
  salesforce_schema: "salesforce_raw"
  
  # Source table names (customize if different)
  salesforce_campaigns_table: "campaigns"
  salesforce_leads_table: "leads"
  salesforce_contacts_table: "contacts"
  salesforce_campaign_members_table: "campaign_members"
  salesforce_opportunities_table: "opportunities"
```

### Model enablement and filtering

Control which models run and set data filtering options:

```yaml
vars:
  # Enable/disable model layers
  salesforce_campaign_funnel__enable_staging_models: true
  salesforce_campaign_funnel__enable_intermediate_models: true  
  salesforce_campaign_funnel__enable_marts_models: true
  
  # Date range filtering for processing
  salesforce_campaign_funnel__start_date: '2020-01-01'
  salesforce_campaign_funnel__end_date: null  # null = no end date limit
  
  # Data quality filters
  salesforce_campaign_funnel__exclude_test_campaigns: true
  salesforce_campaign_funnel__exclude_deleted_records: true
  salesforce_campaign_funnel__exclude_inactive_campaigns: false
  
  # Business logic settings
  salesforce_campaign_funnel__attribution_lookback_days: 90
  salesforce_campaign_funnel__target_currency: 'USD'
  salesforce_campaign_funnel__enable_multi_touch_attribution: true
```

### Custom field mapping

Adapt to your Salesforce org schema by overriding field mappings. This is essential when your Salesforce org uses custom field names or different naming conventions than the default Windsor.ai output.

**Default field mapping structure:**
Each Salesforce object has configurable field mappings that you can override in your `dbt_project.yml`:

```yaml
vars:
  # Campaign field mappings
  salesforce_campaign_funnel__campaigns_id_field: 'campaign_id'
  salesforce_campaign_funnel__campaigns_name_field: 'campaign_name'
  salesforce_campaign_funnel__campaigns_type_field: 'campaign_type'
  salesforce_campaign_funnel__campaigns_status_field: 'campaign_status'
  salesforce_campaign_funnel__campaigns_start_date_field: 'campaign_start_date'
  salesforce_campaign_funnel__campaigns_end_date_field: 'campaign_end_date'
  salesforce_campaign_funnel__campaigns_actual_cost_field: 'campaign_actual_cost'
  salesforce_campaign_funnel__campaigns_budgeted_cost_field: 'campaign_budgeted_cost'
  salesforce_campaign_funnel__campaigns_is_active_field: 'campaign_is_active'
  salesforce_campaign_funnel__campaigns_created_date_field: 'campaign_created_date'
  
  # Lead field mappings
  salesforce_campaign_funnel__leads_id_field: 'lead_id'
  salesforce_campaign_funnel__leads_email_field: 'lead_email'
  salesforce_campaign_funnel__leads_first_name_field: 'lead_first_name'
  salesforce_campaign_funnel__leads_last_name_field: 'lead_last_name'
  salesforce_campaign_funnel__leads_company_field: 'lead_company'
  salesforce_campaign_funnel__leads_status_field: 'lead_status'
  salesforce_campaign_funnel__leads_source_field: 'lead_lead_source'
  salesforce_campaign_funnel__leads_created_date_field: 'lead_created_date'
  salesforce_campaign_funnel__leads_converted_date_field: 'lead_converted_date'
  salesforce_campaign_funnel__leads_converted_contact_id_field: 'lead_converted_contact_id'
  salesforce_campaign_funnel__leads_converted_opportunity_id_field: 'lead_converted_opportunity_id'
```

**Example: Customizing for your org**
If your Salesforce org uses different field names, override them like this:

```yaml
vars:
  # Your org uses 'CampaignId' instead of 'campaign_id'
  salesforce_campaign_funnel__campaigns_id_field: 'CampaignId'
  salesforce_campaign_funnel__campaigns_name_field: 'CampaignName'
  
  # Your org has custom lead fields
  salesforce_campaign_funnel__leads_id_field: 'LeadId'
  salesforce_campaign_funnel__leads_email_field: 'EmailAddress'
  salesforce_campaign_funnel__leads_status_field: 'LeadStatus'
  
  # Your org uses custom opportunity fields
  salesforce_campaign_funnel__opportunities_id_field: 'OpportunityId'
  salesforce_campaign_funnel__opportunities_name_field: 'OpportunityName'
```

### Comprehensive field mapping reference

<details>
<summary><strong>📋 Click to expand complete field mapping options</strong></summary>

#### Campaign field mappings
```yaml
vars:
  salesforce_campaign_funnel__campaigns_id_field: 'campaign_id'
  salesforce_campaign_funnel__campaigns_name_field: 'campaign_name'
  salesforce_campaign_funnel__campaigns_type_field: 'campaign_type'
  salesforce_campaign_funnel__campaigns_status_field: 'campaign_status'
  salesforce_campaign_funnel__campaigns_start_date_field: 'campaign_start_date'
  salesforce_campaign_funnel__campaigns_end_date_field: 'campaign_end_date'
  salesforce_campaign_funnel__campaigns_actual_cost_field: 'campaign_actual_cost'
  salesforce_campaign_funnel__campaigns_budgeted_cost_field: 'campaign_budgeted_cost'
  salesforce_campaign_funnel__campaigns_expected_revenue_field: 'campaign_expected_revenue'
  salesforce_campaign_funnel__campaigns_is_active_field: 'campaign_is_active'
  salesforce_campaign_funnel__campaigns_created_date_field: 'campaign_created_date'
  salesforce_campaign_funnel__campaigns_description_field: 'campaign_description'
```

#### Lead field mappings
```yaml
vars:
  salesforce_campaign_funnel__leads_id_field: 'lead_id'
  salesforce_campaign_funnel__leads_email_field: 'lead_email'
  salesforce_campaign_funnel__leads_first_name_field: 'lead_first_name'
  salesforce_campaign_funnel__leads_last_name_field: 'lead_last_name'
  salesforce_campaign_funnel__leads_company_field: 'lead_company'
  salesforce_campaign_funnel__leads_title_field: 'lead_title'
  salesforce_campaign_funnel__leads_phone_field: 'lead_phone'
  salesforce_campaign_funnel__leads_status_field: 'lead_status'
  salesforce_campaign_funnel__leads_source_field: 'lead_lead_source'
  salesforce_campaign_funnel__leads_created_date_field: 'lead_created_date'
  salesforce_campaign_funnel__leads_converted_date_field: 'lead_converted_date'
  salesforce_campaign_funnel__leads_converted_contact_id_field: 'lead_converted_contact_id'
  salesforce_campaign_funnel__leads_converted_opportunity_id_field: 'lead_converted_opportunity_id'
  salesforce_campaign_funnel__leads_is_converted_field: 'lead_is_converted'
```

#### Contact field mappings  
```yaml
vars:
  salesforce_campaign_funnel__contacts_id_field: 'contact_id'
  salesforce_campaign_funnel__contacts_email_field: 'contact_email'
  salesforce_campaign_funnel__contacts_first_name_field: 'contact_first_name'
  salesforce_campaign_funnel__contacts_last_name_field: 'contact_last_name'
  salesforce_campaign_funnel__contacts_account_id_field: 'contact_accountid'
  salesforce_campaign_funnel__contacts_phone_field: 'contact_phone'
  salesforce_campaign_funnel__contacts_title_field: 'contact_title'
  salesforce_campaign_funnel__contacts_lead_source_field: 'contact_lead_source'
  salesforce_campaign_funnel__contacts_created_date_field: 'contact_createddate'
```

#### Campaign Member field mappings
```yaml
vars:
  salesforce_campaign_funnel__campaign_members_id_field: 'campaignmember_id'
  salesforce_campaign_funnel__campaign_members_campaign_id_field: 'campaignmember_campaign_id'
  salesforce_campaign_funnel__campaign_members_lead_id_field: 'campaignmember_lead_id'
  salesforce_campaign_funnel__campaign_members_contact_id_field: 'campaignmember_contact_id'
  salesforce_campaign_funnel__campaign_members_status_field: 'campaignmember_status'
  salesforce_campaign_funnel__campaign_members_first_responded_date_field: 'campaignmember_first_responded_date'
  salesforce_campaign_funnel__campaign_members_created_date_field: 'campaignmember_created_date'
  salesforce_campaign_funnel__campaign_members_has_responded_field: 'campaignmember_has_responded'
```

#### Opportunity field mappings
```yaml
vars:
  salesforce_campaign_funnel__opportunities_id_field: 'opportunity_id'
  salesforce_campaign_funnel__opportunities_name_field: 'opportunity_name'
  salesforce_campaign_funnel__opportunities_account_id_field: 'opportunity_accountid'
  salesforce_campaign_funnel__opportunities_amount_field: 'opportunity_amount'
  salesforce_campaign_funnel__opportunities_close_date_field: 'opportunity_close_date'
  salesforce_campaign_funnel__opportunities_stage_name_field: 'opportunity_stage_name'
  salesforce_campaign_funnel__opportunities_probability_field: 'opportunity_probability'
  salesforce_campaign_funnel__opportunities_campaign_id_field: 'opportunity_campaign_id'
  salesforce_campaign_funnel__opportunities_created_date_field: 'opportunity_created_date'
  salesforce_campaign_funnel__opportunities_is_closed_field: 'opportunity_is_closed'
  salesforce_campaign_funnel__opportunities_is_won_field: 'opportunity_is_won'
  salesforce_campaign_funnel__opportunities_type_field: 'opportunity_type'
```
</details>

### Picklist value configuration

Configure picklist values to match your Salesforce org's specific values:

```yaml
vars:
  # Campaign types in your org
  salesforce_campaign_funnel__campaign_types:
    - 'Email'
    - 'Webinar'
    - 'Trade Show'
    - 'Social Media'
    - 'Content Marketing'
    - 'Partner Event'
    
  # Lead statuses in your org
  salesforce_campaign_funnel__lead_statuses:
    - 'Open - Not Contacted'
    - 'Working - Contacted' 
    - 'Qualified'
    - 'Unqualified'
    - 'Nurture'
    
  # Opportunity stages in your org
  salesforce_campaign_funnel__opportunity_stages:
    - 'Prospecting'
    - 'Qualification'
    - 'Needs Analysis'
    - 'Proposal/Price Quote'
    - 'Negotiation/Review'
    - 'Closed Won'
    - 'Closed Lost'
```

### Performance configuration

Optimize package performance for your data volume and BigQuery usage:

```yaml
vars:
  # Incremental strategies for large datasets
  salesforce_campaign_funnel__incremental_strategy: 'merge'  # or 'insert_overwrite'
  salesforce_campaign_funnel__lookback_days: 3  # Days to look back for incremental updates
  
  # Resource allocation for large datasets
models:
  salesforce_campaign_funnel:
    marts:
      +labels:
        team: 'marketing'
        cost_center: 'analytics'
      salesforce__campaign_lead_funnel:
        +partition_by:
          field: campaign_created_date
          data_type: date
          granularity: month
        +cluster_by: ['campaign_type', 'campaign_status', 'lead_source']
        +require_partition_filter: true
      
      salesforce__campaign_attribution_summary:
        +partition_by:
          field: opportunity_close_date
          data_type: date
          granularity: month
        +cluster_by: ['campaign_type', 'opportunity_stage_name']
```

**Performance recommendations:**

- **For datasets > 1M rows**: Enable partitioning and clustering as shown above
- **For historical analysis**: Set `start_date` to limit processing window
- **For development**: Use `dbt_project.yml` overrides to limit data during development:
  ```yaml
  vars:
    salesforce_campaign_funnel__start_date: '{{ (modules.datetime.date.today() - modules.datetime.timedelta(days=90)).strftime("%Y-%m-%d") }}'
  ```
- **For cost optimization**: Consider `insert_overwrite` strategy for marts models if you don't need historical snapshots

## 🔧 Utility macros

The package includes helper macros for data transformations:

- `clean_boolean()` - Convert string booleans to proper boolean type
- `clean_email()` - Standardize and validate email addresses  
- `safe_date_parse()` - Robust date parsing with error handling
- `calculate_days_between()` - Date difference calculations
- `clean_currency()` - Numeric/currency field validation
- `clean_phone()` - Phone number standardization

## 🧪 Data quality & testing

Built-in data quality tests include:

- **Uniqueness**: Primary key constraints on all models
- **Referential integrity**: Foreign key relationships between tables  
- **Data validation**: Email format, date ranges, picklist values
- **Business logic**: Conversion funnel consistency checks
- **Completeness**: Required field validation

Run tests with:
```

dbt test
dbt test --select stg_salesforce  \# Test staging models only

```

## 📈 Use cases

Perfect for organizations looking to:

- **Measure marketing ROI** across Salesforce campaigns
- **Optimize lead conversion** with detailed funnel analysis  
- **Understand attribution** across multiple touchpoints
- **Build executive dashboards** with campaign performance
- **Track sales pipeline** from marketing source to closed won

## 📚 Additional resources

- **Package capabilities**: Review `analysis/docs/package_capabilities.md` for feature documentation
- **Field mapping**: Review `analysis/docs/field_mapping.md` for field documentation
- **Macros documentation**: Review `analysis/docs/macros_documentation.md` for detailed macro usage and examples
- **Source documentation**: Review `models/staging/salesforce/sources.yml` for field definitions
- **Model documentation**: Check `schema.yml` files in each layer for model and column documentation
- **Salesforce to BigQuery integration documentation**: Read this guide [https://windsor.ai/connect/salesforce-google-bigquery-integration/](https://windsor.ai/connect/salesforce-google-bigquery-integration/) for available integration methods

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for any new functionality  
4. Submit a pull request with clear description

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.