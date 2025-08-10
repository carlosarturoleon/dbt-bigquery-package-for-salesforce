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

## 🚀 Quick Start

1. Add to your `packages.yml`:
```yaml
packages:
  - git: "https://github.com/carlosarturoleon/dbt-salesforce-campaign-funnel.git"
    revision: main