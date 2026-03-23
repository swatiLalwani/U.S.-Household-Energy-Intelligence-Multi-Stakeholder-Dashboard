# 🔌 U.S. Household Energy Intelligence — Multi-Stakeholder Dashboard

![Tableau](https://img.shields.io/badge/Tableau-Public-blue?logo=tableau) ![Python](https://img.shields.io/badge/Python-3.10-yellow?logo=python) ![SQL](https://img.shields.io/badge/SQL%20Server-SSMS-red?logo=microsoftsqlserver) ![Data](https://img.shields.io/badge/Data-EIA%20RECS%202020-green)

Transforming raw U.S. government survey data into a **unified energy intelligence platform** serving 3 distinct stakeholders — Executive, Operations, and Sustainability — from a single cleaned dataset of **18,477 U.S. households**.

🔗 **[View Live Dashboard on Tableau Public](https://public.tableau.com/views/U_S_HouseholdEnergyIntelligence/Home?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

---

## 📋 Table of Contents
- [🎯 Business Problem](#-business-problem)
- [💡 Solution Overview](#-solution-overview)
- [🧱 Architecture](#-architecture)
- [🔄 Data Pipeline](#-data-pipeline)
- [🧹 Data Quality & Cleaning](#-data-quality--cleaning)
- [📊 Dashboards & Insights](#-dashboards--insights)
- [🛠️ Technical Implementation](#-technical-implementation)
- [📈 Key Results](#-key-results)
- [🎓 Skills Demonstrated](#-skills-demonstrated)

---

## 🎯 Business Problem

**Scenario:** A national energy consultancy needs to analyze residential energy consumption patterns across the United States to support three distinct decision-making teams — each with different priorities, questions, and levels of data literacy.

**Challenge:**
- Raw government survey data contains **600+ columns** across 18,000+ households with no structure for business use
- Different stakeholders need **completely different views** of the same data
- No unified platform connecting energy costs, appliance behavior, and environmental impact
- Manual analysis causing delays and inconsistencies across teams

**Goal:** Build a multi-stakeholder Tableau intelligence platform that transforms raw EIA survey data into three purpose-built dashboards — each answering a distinct set of business questions for a specific audience.

**Project Scope:**

| Stakeholder | Role | Primary Need |
|---|---|---|
| 🏢 Executive | C-Suite / Leadership | Cost trends, regional benchmarks, budget planning |
| ⚙️ Operations | Facility / Energy Manager | Appliance behavior, peak usage, efficiency drivers |
| 🌱 Sustainability | ESG / Analyst | CO2 footprint, fuel mix, energy equity analysis |

---

## 💡 Solution Overview

Built an end-to-end data pipeline and multi-stakeholder Tableau dashboard that unified raw EIA survey data into a single analytical layer:

**Data Integration:**
- Downloaded official 2020 RECS microdata from the U.S. Energy Information Administration (EIA)
- Used Python (pandas + sqlalchemy) to ingest 600+ column CSV into SQL Server
- Built end-to-end SQL transformation pipeline producing 3 purpose-built views

**Data Pipeline (3-Stage Approach):**
```
Raw CSV (600+ cols)  →  SQL Server Staging  →  Cleaned Views  →  Tableau Dashboards
     18,496 rows           recs_main              18,477 rows       3 stakeholder views
```

**Data Quality Transformations:**
- Identified and removed 15 households with $0 electricity cost (unreliable records)
- Detected and excluded 4 extreme outliers consuming 100,000+ kWh (up to 17x the average)
- Engineered 10+ new calculated columns — CO2 emissions, energy intensity, cost per person
- Standardized 600+ raw columns into 3 clean, purpose-built exports

**Deliverables:**
- 4 interactive Tableau dashboards (Home + 3 stakeholder views)
- Full SQL transformation pipeline with data quality documentation
- Calculated sustainability metrics using EPA 2020 US grid emission factors

**Key Metrics (from Dashboard):**

| Metric | Value |
|---|---|
| Total Households Analyzed | 18,477 |
| Total Electricity Consumed | 199,984,614 kWh |
| Total Energy Cost (All Fuels) | $36,742,612 |
| Avg Energy Intensity | 6.61 kWh per sqft |
| Avg Household Size | 2 members |
| Total CO2 Emissions | 77,194 tonnes |
| Avg kWh per Person | 5,222 kWh |
| States Covered | All 50 US States |
| Housing Types | 5 (Mobile Home → Large Apartment) |
| Income Brackets | 16 ($0 → $450K+) |

---

## 🧱 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ INGESTION LAYER                                             │
├─────────────────────────────────────────────────────────────┤
│ • Source: EIA RECS 2020 Microdata (CSV, 600+ columns)       │
│ • Tool: Python (pandas + sqlalchemy + pyodbc)               │
│ • Output: recs_main table in SQL Server (18,496 rows)       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ CLEANING LAYER                                              │
├─────────────────────────────────────────────────────────────┤
│ • Outlier detection (KWH > 100,000 → excluded)              │
│ • Zero-cost removal (DOLLAREL = 0 → excluded)               │
│ • TRY_CAST for safe type conversion (VARCHAR → FLOAT/INT)   │
│ • Output: recs_clean table (18,477 rows)                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ TRANSFORMATION LAYER                                        │
├─────────────────────────────────────────────────────────────┤
│ • Feature engineering (CO2, kwh_per_sqft, kwh_per_person)   │
│ • Label mapping (REGIONC, TYPEHUQ, MONEYPY → readable text) │
│ • End-use % breakdown (pct_ac, pct_heating, pct_other)      │
│ • 3 purpose-built views: executive, operations, sustain.    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ VISUALIZATION LAYER (Tableau Public)                        │
├─────────────────────────────────────────────────────────────┤
│ • 🏠 Home Screen — Stakeholder navigation hub               │
│ • 🏢 Executive Dashboard — Cost, region, income analysis    │
│ • ⚙️ Operations Dashboard — Appliance & efficiency view     │
│ • 🌱 Sustainability Dashboard — CO2 & fuel mix analysis     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Pipeline

**Source System:**

| Source | Format | Columns | Rows |
|---|---|---|---|
| EIA RECS 2020 Microdata | CSV | 600+ | 18,496 |

**Processing Workflow:**

```
📂 Pipeline/

├── load_recs.py                    → Load raw CSV into SQL Server
├── 01_data_quality_check.sql       → Assess nulls, outliers, invalid values
├── 02_create_clean_table.sql       → Remove bad rows → recs_clean (18,477)
├── 03_executive_view.sql           → Cost, region, housing, income breakdown
├── 04_operations_view.sql          → Appliance, fuel, end-use % breakdown
└── 05_sustainability_view.sql      → CO2, fuel mix, energy intensity metrics
```

**Key Transformations:**

**1. Outlier Detection & Removal**
- Identified 4 households consuming 100,000+ kWh annually
- Average consumption is 10,849 kWh — outliers were 9–17x above average
- All 4 were large homes (4,670–8,000 sqft) in Southern states with likely meter errors

**2. Feature Engineering**
```sql
-- CO2 Emissions (EPA 2020 US grid average: 0.386 kg/kWh)
ROUND(TRY_CAST(KWHIN AS FLOAT) * 0.386, 2) AS co2_kg

-- Energy Intensity
ROUND(TRY_CAST(KWHIN AS FLOAT) / NULLIF(TRY_CAST(TOTSQFT_EN AS FLOAT),0), 2) AS kwh_per_sqft

-- Per-Capita Consumption
ROUND(TRY_CAST(KWHIN AS FLOAT) / NULLIF(TRY_CAST(NHSLDMEM AS FLOAT),0), 2) AS kwh_per_person

-- End-Use Breakdown (%)
ROUND(TRY_CAST(KWHCOL AS FLOAT) / NULLIF(TRY_CAST(KWHIN AS FLOAT),0) * 100, 1) AS pct_ac
ROUND(TRY_CAST(KWHSPH AS FLOAT) / NULLIF(TRY_CAST(KWHIN AS FLOAT),0) * 100, 1) AS pct_heating

-- Total Energy Cost (All Fuels)
ROUND(TRY_CAST(DOLLAREL AS FLOAT) + TRY_CAST(DOLLARNG AS FLOAT) +
      TRY_CAST(DOLLARFO AS FLOAT) + TRY_CAST(DOLLARLP AS FLOAT), 2) AS total_energy_cost_usd
```

**3. Label Standardization**
```sql
CASE TRY_CAST(TYPEHUQ AS INT)
    WHEN 1 THEN 'Mobile Home'              WHEN 2 THEN 'Single Family Detached'
    WHEN 3 THEN 'Single Family Attached'   WHEN 4 THEN 'Apartment (2-4 units)'
    WHEN 5 THEN 'Apartment (5+ units)'
END AS housing_type
```

---

## 🧹 Data Quality & Cleaning

| Check | Finding | Action | Rows Affected |
|---|---|---|---|
| NULL values in key columns | 0 nulls across all metrics | No action needed | 0 |
| Zero electricity cost | $0 DOLLAREL — unreliable records | Excluded | 15 |
| Extreme KWH outliers | 4 households > 100,000 kWh (avg: 10,849) | Excluded | 4 |
| Zero square footage | 0 records | No action needed | 0 |
| Invalid type conversions | VARCHAR stored numerics | TRY_CAST for safe conversion | All rows |
| **Final clean dataset** | | | **18,477 rows** |

---

## 📊 Dashboards & Insights

### 🏠 Home Screen
- Central navigation hub routing each stakeholder to their view
- Project description with data source attribution
- 3 color-coded navigation buttons (Blue / Orange / Green)
- Back-to-home button on every dashboard

---

### 🏢 Executive Dashboard
**Audience:** C-Suite, VP Finance, Budget Owners

**Dashboard KPIs:**
| Metric | Value |
|---|---|
| Total Electricity Consumed | 199,984,614 kWh |
| Total Energy Cost | $36,742,612 |
| Avg Energy Intensity | 6.61 kWh/sqft |
| Avg Household Size | 2 members |

**Charts:**
- KPI tiles — Total kWh, Total Cost, Avg kWh/sqft, Avg Household Members
- US Choropleth Map — Total kWh consumption by state
- Bar chart — Total energy cost by US region (West, South, Northeast, Midwest)
- Bar chart — Total energy cost by income bracket (16 levels, $20K → $450K+)

**Key Insights:**

> 💡 **The South is the most expensive region for energy** — accounting for the highest total energy cost of all 4 US regions, driven by heavy air conditioning demand in hot-humid climates across Texas, Florida, and the Gulf states.

> 💡 **Energy costs rise sharply with income** — the $450K+ income bracket has the highest total energy cost of all 16 brackets, reflecting larger homes, more appliances, and less incentive to conserve. The jump from lower to upper income brackets is clearly visible in the bar chart.

> 💡 **The average US household uses 6.61 kWh per square foot annually** — a useful benchmark for identifying inefficient homes. Households significantly above this figure are candidates for efficiency interventions.

> 💡 **Average household size is just 2 members** — meaning per-capita energy consumption is relatively high, as fixed costs like heating and cooling are shared across fewer people than in larger households.

---

### ⚙️ Operations Dashboard
**Audience:** Energy Managers, Facility Operators, Building Engineers

**Charts:**
- Stacked bar — Energy breakdown by end-use (AC / Heating / Water Heating / Other) across housing types
- Bar chart — Total kWh by heating fuel type (Natural Gas, Electricity, Propane, Fuel Oil, Wood)
- Bar chart — AC kWh by cooling equipment type (Central AC, Window Units, Both, None)
- Scatter plot — Home sqft vs total kWh consumption by housing type

**Key Insights:**

> 💡 **Single Family Detached homes completely dominate energy consumption** — accounting for the vast majority of total kWh across every end-use category (AC, heating, water heating, and other). This single housing type is the primary driver of US residential energy demand.

> 💡 **Natural Gas is the dominant heating fuel nationally** — significantly outpacing Electricity, Propane, Fuel Oil, and Wood in total kWh consumed for heating. This reflects the widespread gas infrastructure across Midwest and Northeast states where heating loads are highest.

> 💡 **Central AC drives the overwhelming majority of cooling energy** — households with Central AC consume far more AC kWh than those with window/wall units or no AC. The "Both" category (Central + window units) shows the highest per-household cooling load.

> 💡 **Home size and energy use are directly correlated** — the scatter plot shows a clear positive relationship between sqft and total kWh across all housing types. Single Family Detached homes cluster in the high-sqft, high-kWh zone while apartments concentrate in the low-sqft, low-kWh zone.

---

### 🌱 Sustainability Dashboard
**Audience:** ESG Teams, Sustainability Analysts, Policy Researchers

**Dashboard KPIs:**
| Metric | Value |
|---|---|
| Total CO2 Emissions | 77,194 tonnes |
| Avg kWh per Person | 5,222 kWh |
| Avg kWh per sqft | 6.609 kWh |

**Charts:**
- KPI tiles — Total CO2 (tonnes), Avg kWh/person, Avg kWh/sqft
- US Choropleth Map — CO2 emissions by state
- Bar chart — Total CO2 (kg) by housing type
- Bar chart — kWh per person by income bracket

**Key Insights:**

> 💡 **Single Family Detached homes are responsible for the most CO2 by a wide margin** — generating over 60M kg of CO2 annually compared to significantly lower figures for Single Family Attached, Mobile Homes, and Apartments. Reducing energy use in this housing type would have the greatest environmental impact.

> 💡 **kWh per person rises consistently with income** — the bar chart shows a clear staircase pattern from lower to upper income brackets, with $450K+ households consuming the most kWh per person. This confirms that higher-income households are less energy-efficient on a per-capita basis despite having access to more efficient appliances.

> 💡 **The average American household generates 77,194 tonnes of CO2 in aggregate** — at 5,222 kWh per person and a US grid emission factor of 0.386 kg/kWh, the average individual's residential electricity use generates approximately 2,016 kg (2 tonnes) of CO2 annually.

> 💡 **Apartments are the most carbon-efficient housing type** — both Apartment (2-4 units) and Apartment (5+ units) show dramatically lower CO2 per household than detached homes, reinforcing the environmental case for urban density and multi-family housing.

---

### Cross-Dashboard Insights

> ✅ **The South has the highest energy costs AND the highest CO2** — making it the single highest-priority region for both cost reduction and sustainability interventions simultaneously.

> ✅ **Apartments are the most sustainable and most affordable housing type** — lowest CO2 per household, lowest kWh per sqft, and lowest total energy cost across all 5 housing categories.

> ✅ **Energy costs and income are correlated but not proportional** — higher-income households spend more in absolute terms but the lower-income brackets ($20K–$60K) spend a disproportionate share of their income on energy, highlighting an energy affordability issue at the bottom of the income distribution.

---

## 🛠️ Technical Implementation

**Tech Stack:**

| Layer | Technology | Purpose |
|---|---|---|
| Ingestion | Python (pandas, sqlalchemy, pyodbc) | Load 600-col CSV into SQL Server |
| Storage | SQL Server / SSMS | Staging, cleaning, transformation |
| Transformation | SQL (TRY_CAST, CASE, NULLIF, ROUND) | Feature engineering, label mapping |
| Visualization | Tableau Public | 4 interactive dashboards |
| Version Control | Git / GitHub | Code & documentation |

**Data Model:**
```
recs_main (raw)          recs_clean (filtered)
18,496 rows         →    18,477 rows
600+ columns             41 selected columns
                              ↓
              ┌───────────────┼───────────────┐
              ↓               ↓               ↓
     executive_view   operations_view  sustainability_view
      12 columns        20 columns        22 columns
```

**Key Technical Challenges Solved:**

**Challenge 1: 600-Column CSV Import Failure**

Problem: SSMS "Import Flat File" wizard crashed with `FillWeight > 65535` error due to column count.

Solution: Used Python with sqlalchemy to load only the 41 required columns directly, bypassing SSMS entirely.
```python
cols = ['DOEID', 'REGIONC', 'KWH', 'KWHCOL', 'KWHSPH', ...]
df = pd.read_csv(r'C:\recs2020_public_v7.csv', usecols=cols)
df.to_sql('recs_main', engine, if_exists='replace', index=False)
```
Result: Clean 18,496 row table loaded in under 60 seconds.

---

**Challenge 2: VARCHAR Stored Numerics**

Problem: All 600+ columns imported as VARCHAR. Standard CAST failed on mixed/invalid values.

Solution: Used `TRY_CAST` throughout — silently returns NULL for unconvertible values instead of crashing.
```sql
TRY_CAST(KWHIN AS FLOAT)    AS total_kwh
TRY_CAST(NHSLDMEM AS INT)   AS household_members
```
Result: 100% conversion success across all 18,477 rows with zero pipeline failures.

---

**Challenge 3: Mixed Text/Numeric Code Labels**

Problem: Columns like REGIONC stored as text (`'WEST'`, `'SOUTH'`) while others stored as numeric codes. Standard CASE with integer matching failed.

Solution: Wrapped CASE expressions with `TRY_CAST` to handle both representations safely.
```sql
CASE TRY_CAST(TYPEHUQ AS INT)
    WHEN 1 THEN 'Mobile Home'
    WHEN 2 THEN 'Single Family Detached'
    ELSE TYPEHUQ
END AS housing_type
```
Result: Clean readable labels across all dimension columns with no data loss.

---

## 📈 Key Results

**Business Impact:**

✅ Unified 18,477 household records into a single cleaned analytical dataset  
✅ Delivered 3 stakeholder-specific dashboards each answering distinct business questions  
✅ Engineered 10+ calculated metrics — CO2 emissions, energy intensity, per-capita consumption  
✅ Identified $0-cost data quality issue affecting 15 records before dashboard build  
✅ Detected 4 extreme outlier households (9–17x average consumption) preventing skewed analysis  

**Data Engineering Achievements:**

✅ Navigated 600+ column government dataset — selected 41 relevant columns  
✅ Built 3-stage SQL pipeline: raw → clean → purpose-built views  
✅ Used Python to overcome SSMS import limitations on wide datasets  
✅ Applied safe type conversion patterns (TRY_CAST) across all numeric fields  
✅ Engineered CO2 metrics using EPA 2020 US grid emission factor (0.386 kg/kWh)  

**Strategic Insights Delivered:**

📊 Regional — South confirmed as highest-cost and highest-CO2 region ($36.7M total energy cost)  
📈 Housing — Single Family Detached generates 60M+ kg CO2 vs near-zero for apartments  
🌱 Income — kWh per person rises consistently across all 16 income brackets  
⚙️ Fuel — Natural Gas dominates heating nationally; Central AC dominates cooling demand  

---

## 🎓 Skills Demonstrated

**Data Engineering**  
✅ End-to-end ETL pipeline design (Python → SQL Server → Tableau)  
✅ Data quality assessment and outlier detection  
✅ Feature engineering (CO2, intensity, per-capita metrics)  
✅ Safe type conversion patterns (TRY_CAST)  
✅ Wide dataset handling (600+ columns)  
✅ Purpose-built view design for multiple audiences  

**Analytics & BI**  
✅ Multi-stakeholder dashboard design  
✅ KPI definition for energy and sustainability domains  
✅ US geographic analysis (state-level choropleth maps)  
✅ Insight generation from government survey data  
✅ Data storytelling across Executive, Operations, and ESG personas  

**Technical Tools**  
✅ Python: pandas, sqlalchemy, pyodbc  
✅ SQL Server / SSMS: DDL, DML, TRY_CAST, CASE, NULLIF  
✅ Tableau Public: Maps, bar charts, scatter plots, KPI tiles, navigation buttons  
✅ Git: Version control and documentation  

**Business Acumen**  
✅ Energy domain knowledge (kWh, BTU, CO2 emission factors)  
✅ Stakeholder persona mapping  
✅ Government data sourcing and interpretation  
✅ Cross-functional dashboard design  

---

## 👤 Author

**Swati Lalwani**
- 📊 Tableau Public: [U.S. Household Energy Intelligence]([https://public.tableau.com/app/profile/swati.thakurbhai.lalwani/viz/U_S_HouseholdEnergyIntelligence/Home](https://public.tableau.com/views/U_S_HouseholdEnergyIntelligence/Home?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link))
- 💼 Portfolio: [datascienceportfol.io/swatilalwani342](https://www.datascienceportfol.io/swatilalwani342)


---

## 📄 License

This project uses publicly available data from the U.S. Energy Information Administration.  
Data is free to use under EIA's open data policy: https://www.eia.gov/about/copyrights_reuse.php


