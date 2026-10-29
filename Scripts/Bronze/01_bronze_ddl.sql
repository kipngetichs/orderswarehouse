/*
=====================================================================
Script:   01_bronze_ddl.sql
Purpose:  Create the Bronze tables for the raw customers and orders
          CSV files. Columns match the source files exactly.
Notes:    Every column is VARCHAR(50) so that dirty values (bad dates,
          text in number columns, blanks) never make the load fail.
          Types are fixed later in the Silver layer.
=====================================================================
*/

USE orderswarehouse;   -- make sure the tables are created in the right database
GO

-- ---------------------------------------------------------------
-- Table 1: raw customers (source file: raw_customers.csv, 500 rows)
-- ---------------------------------------------------------------

-- Drop the table if it already exists, so the script can be re-run
IF OBJECT_ID('bronze.raw_customer', 'U') IS NOT NULL
    DROP TABLE bronze.raw_customer;
GO

CREATE TABLE bronze.raw_customer
(
    id                VARCHAR(50),   -- source row number
    batch_id          VARCHAR(50),   -- load batch (1 to 24), used later to pick the latest record
    customer_code     VARCHAR(50),   -- business key, e.g. C-937 (not unique in the source)
    first_name        VARCHAR(50),   -- may be blank
    last_name         VARCHAR(50),   -- may be blank
    email             VARCHAR(50),   -- may be blank
    phone             VARCHAR(50),   -- format (999) 999-9999, may be blank
    country_raw       VARCHAR(50),   -- many spellings: DE, Germany, germany, US, USA ...
    status_raw        VARCHAR(50),   -- many spellings: active, Active, actv, n/a ...
    signup_date_text  VARCHAR(50),   -- date stored as text, most values are invalid
    last_order_text   VARCHAR(50),   -- date stored as text, most values are invalid
    age_raw           VARCHAR(50),   -- includes negative and unrealistic ages
    credit_limit_text VARCHAR(50),   -- European number format, e.g. 2.931,28
    tags_raw          VARCHAR(50)    -- space-separated tags, e.g. vip b2b
);
GO

-- ---------------------------------------------------------------
-- Table 2: raw orders (source file: raw_orders.csv, 900 rows)
-- ---------------------------------------------------------------

-- Drop the table if it already exists, so the script can be re-run
IF OBJECT_ID('bronze.raw_orders', 'U') IS NOT NULL
    DROP TABLE bronze.raw_orders;
GO

CREATE TABLE bronze.raw_orders
(
    id              VARCHAR(50),   -- source row number
    batch_id        VARCHAR(50),   -- load batch (1 to 24)
    order_ref       VARCHAR(50),   -- order number, e.g. ORD-2961 (repeats in the source)
    customer_code   VARCHAR(50),   -- links to customers (many have no match)
    ordered_at_text VARCHAR(50),   -- timestamp stored as text, most values are invalid
    amount          VARCHAR(50),   -- may be blank or negative
    currency_raw    VARCHAR(50),   -- EUR, eur, USD, usd, GBP, $, symbol variants
    quantity        VARCHAR(50),   -- whole numbers, many are 0
    status_raw      VARCHAR(50)    -- pending, shipped, delivered, cancelled, canceled
);
GO
