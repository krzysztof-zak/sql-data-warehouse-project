# SQL Data Warehouse Project

## Business Problem

Organizations often store data across multiple operational systems, making reporting and analytics difficult due to inconsistent formats, duplicated records, and fragmented business information.

The goal of this project was to build a centralized SQL Data Warehouse that:

* Consolidates customer, product, and sales data from multiple source systems
* Cleans and standardizes raw operational data
* Provides a single source of truth for business reporting
* Enables fast analytical queries through dimensional modeling
* Supports future Business Intelligence and reporting initiatives

---

## Overview

This project implements a modern SQL Data Warehouse using a multi-layer architecture (**Bronze → Silver → Gold**).

The solution integrates data from CRM and ERP systems, applies data quality checks and transformations, and delivers business-ready analytical datasets through a dimensional model optimized for reporting.

**Note:** This project was completed as part of the *Data Warehouse Project Course* by Data With Baraa and serves as a portfolio project demonstrating practical SQL, ETL, and Data Warehousing concepts.

---

## Solution Architecture

```text
Source Systems
      │
      ▼
┌─────────────┐
│   Bronze    │
│ Raw Data    │
└─────────────┘
      │
      ▼
┌─────────────┐
│   Silver    │
│ Clean Data  │
└─────────────┘
      │
      ▼
┌─────────────┐
│    Gold     │
│ Business    │
│ Analytics   │
└─────────────┘
```

---

## Architecture Diagram

```text
                      ┌────────────────────┐
                      │    CRM System      │
                      └─────────┬──────────┘
                                │
                      ┌─────────▼──────────┐
                      │    ERP System      │
                      └─────────┬──────────┘
                                │
                                ▼
                   ┌─────────────────────────┐
                   │      Bronze Layer       │
                   │     Raw Source Data     │
                   └───────────┬─────────────┘
                               │
                               ▼
                   ┌─────────────────────────┐
                   │      Silver Layer       │
                   │ Cleansing & Validation  │
                   └───────────┬─────────────┘
                               │
                               ▼
                   ┌─────────────────────────┐
                   │       Gold Layer        │
                   │ Dimensional Model       │
                   └───────────┬─────────────┘
                               │
                ┌──────────────┼──────────────┐
                ▼              ▼              ▼
      dim_customers   fact_sales   dim_products
```

---

## Data Model

The Gold layer follows a Star Schema design.

### Fact Table

#### `gold.fact_sales`

Stores transactional sales data and business metrics.

**Key Metrics**

* Sales Amount
* Quantity Sold
* Product Price

**Key Dates**

* Order Date
* Shipping Date
* Due Date

### Dimension Tables

#### `gold.dim_customers`

Contains customer-related attributes.

* Customer ID
* Customer Number
* Full Name
* Country
* Gender
* Marital Status
* Birth Date

#### `gold.dim_products`

Contains product hierarchy and classification information.

* Product ID
* Product Name
* Category
* Subcategory
* Product Line
* Standard Cost

---

## ETL Process

### Bronze Layer

Stores raw data exactly as received from source systems.

**Purpose**

* Preserve original data
* Support auditing and traceability
* Provide a reliable staging area

### Silver Layer

Cleans, standardizes, and validates source data.

**Transformations**

* Data cleansing
* Duplicate removal
* Standardization
* Data type conversion
* Business rule validation
* Null handling

### Gold Layer

Provides business-ready analytical datasets.

**Outputs**

* Dimension tables
* Fact tables
* Star schema model
* Reporting-ready structures

---

## Key Achievements

✔ Designed and implemented a multi-layer Data Warehouse architecture

✔ Integrated data from CRM and ERP source systems

✔ Developed ETL processes using SQL Server and T-SQL

✔ Applied data cleansing and validation techniques

✔ Built analytical fact and dimension tables

✔ Implemented a Star Schema for reporting and analytics

✔ Created stored procedures for data loading

✔ Established naming conventions and project documentation

✔ Implemented data quality checks within the Silver layer

---

## SQL Skills Demonstrated

### Database Design

* Data Warehouse Architecture
* Star Schema Design
* Dimensional Modeling
* Fact & Dimension Modeling
* Schema Design

### SQL Development

* DDL (CREATE, ALTER)
* DML (INSERT, UPDATE)
* JOIN Operations
* Common Table Expressions (CTEs)
* CASE Expressions
* Aggregations
* Data Type Conversions
* View Creation

### ETL & Data Engineering

* Data Extraction
* Data Transformation
* Data Loading
* Data Cleansing
* Data Standardization
* Data Validation
* Data Quality Checks

### Data Quality

* Duplicate Detection
* Null Value Analysis
* Business Rule Validation
* Referential Integrity Validation

---

## Technologies Used

| Technology                          | Purpose                   |
| ----------------------------------- | ------------------------- |
| Microsoft SQL Server                | Database Platform         |
| T-SQL                               | Data Transformation & ETL |
| SQL Server Management Studio (SSMS) | Development Environment   |
| Git & GitHub                        | Version Control           |
| Star Schema                         | Analytical Modeling       |
| Data Warehouse Architecture         | Data Platform Design      |

---

## Project Structure

```text
sql-data-warehouse-project-main
│
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── docs/
│   ├── Data Architecture.png
│   ├── Data Catalog.md
│   ├── Data Flow Diagram.png
│   ├── Data Integration.png
│   ├── Data Model.png
│   └── Naming Conventions.md
│
├── scripts/
│   ├── init_database.sql
│   │
│   ├── bronze/
│   │   ├── ddl_bronze.SQL
│   │   └── proc_load_bronze.SQL
│   │
│   ├── silver/
│   │   ├── ddl_silver.SQL
│   │   └── proc_load_silver.SQL
│   │
│   └── gold/
│       └── ddl_gold.sql
│
├── tests/
│   ├── Quality_checks_gold.sql
│   └── Quality_checks_silver.sql
│
├── LICENSE
└── README.md
```

---

## Course Information

This project was developed as part of the **Data Warehouse Project Course** by Data With Baraa.

The course focuses on practical implementation of:

* Data Warehouse Architecture
* SQL Server Development
* ETL Design
* Data Quality Validation
* Dimensional Modeling
* Analytical Data Modeling

The project serves as a hands-on implementation of modern data warehousing principles and demonstrates practical SQL development skills.

---

## What This Project Demonstrates

This project showcases practical experience in:

* SQL Development
* Data Warehousing
* ETL Pipeline Design
* Data Modeling
* Data Quality Validation
* Dimensional Modeling
* Analytical Database Design

Key concepts demonstrated include:

* Bronze, Silver, and Gold architecture
* Data cleansing and transformation
* Fact and dimension table design
* Star schema implementation
* Stored procedures for data loading
* SQL-based data validation
* Documentation and naming standards

```
```
