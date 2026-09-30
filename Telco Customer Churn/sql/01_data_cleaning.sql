-- ============================================================================
-- 01_data_cleaning.sql
-- Purpose : Validate the raw Kaggle table and build a typed, analysis-ready table.
-- Engine  : Google BigQuery (Standard SQL)
-- Source  : telco-customer-churn-488312.telco_customer_churn.`Telcom Customer Churn`
-- Output  : telco-customer-churn-488312.telco_customer_churn.`Telcom Customer Churn Typed`
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Data quality checks (run before transforming)
-- ----------------------------------------------------------------------------

-- 1a. Duplicate customers: expect 0 rows (customerID should be unique)
SELECT
  customerID,
  COUNT(*) AS cnt
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn`
GROUP BY customerID
HAVING cnt > 1;

-- 1b. Null profile across every column
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(customerID IS NULL)       AS customerID_nulls,
  COUNTIF(gender IS NULL)           AS gender_nulls,
  COUNTIF(SeniorCitizen IS NULL)    AS seniorCitizen_nulls,
  COUNTIF(Partner IS NULL)          AS Partner_nulls,
  COUNTIF(Dependents IS NULL)       AS Dependents_nulls,
  COUNTIF(tenure IS NULL)           AS tenure_nulls,
  COUNTIF(PhoneService IS NULL)     AS PhoneService_nulls,
  COUNTIF(MultipleLines IS NULL)    AS MultipleLines_nulls,
  COUNTIF(InternetService IS NULL)  AS InternetService_nulls,
  COUNTIF(OnlineSecurity IS NULL)   AS OnlineSecurity_nulls,
  COUNTIF(OnlineBackup IS NULL)     AS OnlineBackup_nulls,
  COUNTIF(DeviceProtection IS NULL) AS DeviceProtection_nulls,
  COUNTIF(TechSupport IS NULL)      AS TechSupport_nulls,
  COUNTIF(StreamingTV IS NULL)      AS StreamingTV_nulls,
  COUNTIF(StreamingMovies IS NULL)  AS StreamingMovies_nulls,
  COUNTIF(Contract IS NULL)         AS Contract_nulls,
  COUNTIF(PaperlessBilling IS NULL) AS PaperlessBilling_nulls,
  COUNTIF(PaymentMethod IS NULL)    AS PaymentMethod_nulls,
  COUNTIF(MonthlyCharges IS NULL)   AS MonthlyCharges_nulls,
  COUNTIF(TotalCharges IS NULL)     AS TotalCharges_nulls,
  COUNTIF(Churn IS NULL)            AS Churn_nulls
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn`;

-- 1c. TotalCharges is stored as text in the source. Blank values belong to
--     customers with tenure = 0 (brand-new accounts that have not been billed yet).
SELECT
  COUNT(*) AS blank_total_charges_rows,
  COUNTIF(tenure = 0) AS of_which_tenure_zero
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn`
WHERE TRIM(TotalCharges) = '';

-- ----------------------------------------------------------------------------
-- 2. Build the typed table
--    * Yes/No style columns become 1/0 flags (INT64)
--    * TotalCharges is converted from text to FLOAT64
--    * Blank TotalCharges (tenure = 0) is set to 0.0 because nothing was billed yet
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE
  `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed` AS
SELECT
  customerID,
  gender,
  IFNULL(CAST(SeniorCitizen AS INT64), 0)    AS senior_citizen_flag,
  IFNULL(CAST(Partner AS INT64), 0)          AS partner_flag,
  IFNULL(CAST(Dependents AS INT64), 0)       AS dependents_flag,
  tenure,
  IFNULL(CAST(PhoneService AS INT64), 0)     AS phone_service_flag,
  MultipleLines,
  InternetService,
  OnlineSecurity,
  OnlineBackup,
  DeviceProtection,
  TechSupport,
  StreamingTV,
  StreamingMovies,
  Contract,
  IFNULL(CAST(PaperlessBilling AS INT64), 0) AS paperless_billing_flag,
  PaymentMethod,
  MonthlyCharges,
  CASE
    WHEN tenure = 0 THEN 0.0
    ELSE SAFE_CAST(NULLIF(TRIM(TotalCharges), '') AS FLOAT64)
  END                                        AS total_charges,
  IFNULL(CAST(Churn AS INT64), 0)            AS churn_flag
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn`;

-- ----------------------------------------------------------------------------
-- 3. Post-build validation
-- ----------------------------------------------------------------------------

-- Row count must match the raw table (7,043) and no total_charges should be NULL
SELECT
  COUNT(*)                          AS total_rows,
  COUNTIF(total_charges IS NULL)    AS null_total_charges,
  COUNTIF(churn_flag = 1)           AS churned_customers
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`;
