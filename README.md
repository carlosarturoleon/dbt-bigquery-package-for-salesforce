# dbt Salesforce Campaign Funnel

**A production-ready dbt package that transforms raw Salesforce data into campaign funnel analytics for BigQuery.**

Transform your Salesforce campaign data into actionable marketing intelligence with complete lead → contact → opportunity attribution tracking.

## What does this dbt package do?

This package transforms raw Salesforce data into clean, analytics ready tables modeling the complete **Campaign → Lead → Contact → Campaign Member → Opportunity** funnel. It provides:

- **Campaign ROI analysis**: Track performance metrics across campaigns
- **Lead conversion tracking**: Monitor progression with timing analytics  
- **Multi touch attribution**: Understand campaign touchpoint impact
- **Executive dashboards**: Ready to use models for business intelligence
- **Data quality assurance**: Built in validation and testing

## 📋 Requirements

To use this dbt package, you must have the following:

- **dbt Core** >= 1.0.0
- **BigQuery** data warehouse (currently supported)
- **Salesforce source data** synced to your data warehouse
- The following source tables available in your BigQuery project:
  - `campaigns`
  - `leads` 
  - `contacts`
  - `campaign_members`
  - `opportunities`

## 🚀 Quick Start

### Step 1: Install the Package

Add to your `packages.yml`:

```

packages:

- git: "https://github.com/carlosarturoleon/dbt-salesforce-campaign-funnel.git"
revision: main

```

### Step 2: Install Dependencies

```

dbt deps

```

### Step 3: Configure Source Tables

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

### Step 4: Run the Models

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

## 🏗️ Package Architecture

This package follows dbt best practices with a three layer architecture:

### **Staging Models** (`stg_salesforce__*`)
Clean and standardize raw Salesforce data with:
- Data type standardization
- Consistent field naming
- Basic data validation
- Null handling

### **Intermediate Models** (`int_salesforce__*`)  
Business logic and metric calculations including:
- Lead journey progression tracking
- Campaign performance aggregations
- Attribution calculations
- Conversion timing analysis

### **Marts Models** (`salesforce__*`)
Analytics ready final tables optimized for:
- Executive reporting
- Dashboard integration
- BigQuery performance (partitioned/clustered)
- Business user consumption

## 📊 Models Reference

| **Model** | **Description** |
|-----------|-----------------|
| `stg_salesforce__campaigns` | Cleaned campaign master data |
| `stg_salesforce__leads` | Standardized lead information |
| `stg_salesforce__contacts` | Clean contact records |
| `stg_salesforce__campaign_members` | Campaign membership data |
| `stg_salesforce__opportunities` | Opportunity pipeline data |
| `int_salesforce__lead_journey` | Lead progression and timing |
| `int_salesforce__campaign_performance` | Campaign metrics and KPIs |
| `int_salesforce__contact_touchpoints` | Contact interaction history |
| `salesforce__campaign_lead_funnel` | **Complete funnel analysis** |
| `salesforce__campaign_attribution_summary` | **Multi-touch attribution reporting** |

## ⚙️ Configuration Options

### Custom Field Mapping

Adapt to your Salesforce org schema by overriding field mappings in `dbt_project.yml`:

```

vars:

# Campaign field mappings

campaigns_id_field: 'Id'
campaigns_name_field: 'Name'
campaigns_type_field: 'Type'
campaigns_status_field: 'Status'

# Lead field mappings

leads_id_field: 'Id'
leads_email_field: 'Email'
leads_status_field: 'Status'
leads_source_field: 'LeadSource'

```

### Picklist Value Configuration

Configure picklist values to match your Salesforce org:

```

vars:
salesforce_campaign_types:
- 'Email'
- 'Webinar'
- 'Trade Show'
- 'Social Media'

salesforce_lead_statuses:
- 'Open - Not Contacted'
- 'Working - Contacted'
- 'Qualified'
- 'Unqualified'

```

### Schema Configuration

Customize output schemas:

```

models:
salesforce_campaign_funnel:
+schema: my_salesforce_schema
staging:
+schema: my_staging_schema
intermediate:
+schema: my_intermediate_schema

```

## 🔧 Utility Macros

The package includes helper macros for data transformations:

- `clean_boolean()` - Convert string booleans to proper boolean type
- `clean_email()` - Standardize and validate email addresses  
- `safe_date_parse()` - Robust date parsing with error handling
- `calculate_days_between()` - Date difference calculations
- `clean_currency()` - Numeric/currency field validation
- `clean_phone()` - Phone number standardization

## 🧪 Data Quality & Testing

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

## 📈 Use Cases

Perfect for organizations looking to:

- **Measure marketing ROI** across Salesforce campaigns
- **Optimize lead conversion** with detailed funnel analysis  
- **Understand attribution** across multiple touchpoints
- **Build executive dashboards** with campaign performance
- **Track sales pipeline** from marketing source to closed won

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for any new functionality  
4. Submit a pull request with clear description

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.