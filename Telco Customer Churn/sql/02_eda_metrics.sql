-- ============================================================================
-- 02_eda_metrics.sql
-- Purpose : Core churn KPIs and segment breakdowns (mirrors the dashboard).
-- Source  : `Telcom Customer Churn Typed` (created in 01_data_cleaning.sql)
-- Definitions:
--   churn rate  = churned customers / total customers
--   MRR lost    = SUM(MonthlyCharges) of churned customers
--                 (monthly recurring revenue that left the business)
-- ============================================================================

-- 1. Headline KPIs -----------------------------------------------------------
SELECT
  COUNT(*)                                                   AS total_customers,
  COUNTIF(churn_flag = 1)                                    AS total_churned,
  ROUND(AVG(churn_flag) * 100, 2)                            AS churn_rate_pct,
  ROUND(SUM(IF(churn_flag = 1, MonthlyCharges, 0)), 2)       AS total_mrr_lost,
  ROUND(SUM(MonthlyCharges), 2)                              AS total_mrr_base,
  ROUND(SUM(IF(churn_flag = 1, MonthlyCharges, 0))
        / SUM(MonthlyCharges) * 100, 2)                      AS mrr_lost_pct
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`;

-- 2. Churn by contract type --------------------------------------------------
SELECT
  Contract,
  COUNT(*)                                              AS customers,
  COUNTIF(churn_flag = 1)                               AS churned,
  ROUND(AVG(churn_flag) * 100, 2)                       AS churn_rate_pct,
  ROUND(SUM(IF(churn_flag = 1, MonthlyCharges, 0)), 2)  AS mrr_lost
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- 3. Churn by internet service -----------------------------------------------
SELECT
  InternetService,
  COUNT(*)                                              AS customers,
  COUNTIF(churn_flag = 1)                               AS churned,
  ROUND(AVG(churn_flag) * 100, 2)                       AS churn_rate_pct,
  ROUND(SUM(IF(churn_flag = 1, MonthlyCharges, 0)), 2)  AS mrr_lost
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

-- 4. Churn by payment method -------------------------------------------------
SELECT
  PaymentMethod,
  COUNT(*)                                              AS customers,
  COUNTIF(churn_flag = 1)                               AS churned,
  ROUND(AVG(churn_flag) * 100, 2)                       AS churn_rate_pct,
  ROUND(SUM(IF(churn_flag = 1, MonthlyCharges, 0)), 2)  AS mrr_lost
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- 5. Churn by tenure group (same buckets as the Looker Studio calculated field)
SELECT
  CASE
    WHEN tenure <= 12 THEN '0-1 Year'
    WHEN tenure <= 24 THEN '1-2 Years'
    WHEN tenure <= 36 THEN '2-3 Years'
    WHEN tenure <= 48 THEN '3-4 Years'
    WHEN tenure <= 60 THEN '4-5 Years'
    ELSE '5+ Years'
  END                                                   AS tenure_year_group,
  COUNT(*)                                              AS customers,
  COUNTIF(churn_flag = 0)                               AS retained,
  COUNTIF(churn_flag = 1)                               AS churned,
  ROUND(AVG(churn_flag) * 100, 2)                       AS churn_rate_pct
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY tenure_year_group
ORDER BY MIN(tenure);

-- 6. Average monthly charges: churned vs retained ----------------------------
SELECT
  IF(churn_flag = 1, 'Churned', 'Retained')  AS churn_status,
  COUNT(*)                                   AS customers,
  ROUND(AVG(MonthlyCharges), 2)              AS avg_monthly_charges
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY churn_status;

-- 7. Additional segments worth checking (extend the story) -------------------
-- 7a. Add-on services: do protection/support services relate to lower churn?
SELECT 'OnlineSecurity' AS service, OnlineSecurity AS value,
       COUNT(*) AS customers, ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY value
UNION ALL
SELECT 'TechSupport', TechSupport,
       COUNT(*), ROUND(AVG(churn_flag) * 100, 2)
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY TechSupport
ORDER BY service, churn_rate_pct DESC;

-- 7b. Demographics
SELECT
  senior_citizen_flag, partner_flag, dependents_flag,
  COUNT(*) AS customers,
  ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
GROUP BY senior_citizen_flag, partner_flag, dependents_flag
ORDER BY churn_rate_pct DESC;

-- 7c. Highest-risk combination: month-to-month + fiber + electronic check
SELECT
  COUNT(*) AS customers,
  ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct,
  ROUND(SUM(IF(churn_flag = 1, MonthlyCharges, 0)), 2) AS mrr_lost
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
WHERE Contract = 'Month-to-month'
  AND InternetService = 'Fiber optic'
  AND PaymentMethod = 'Electronic check';
