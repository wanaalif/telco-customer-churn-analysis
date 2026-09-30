-- ============================================================================
-- 03_dashboard_view.sql
-- Purpose : Final, dashboard-facing view that Looker Studio connects to.
-- Notes   : Column names are kept identical to the typed table so the
--           Looker Studio calculated fields keep working unchanged:
--             churn_status        -> CASE on churn_flag
--             tenure_year_group   -> CASE on tenure
--             churn_rate          -> AVG(churn_flag)
--             total_revenue_lost  -> SUM(CASE WHEN churn_flag = 1
--                                        THEN MonthlyCharges ELSE 0 END)
-- ============================================================================
CREATE OR REPLACE VIEW
  `telco-customer-churn-488312.telco_customer_churn.vw_churn_dashboard` AS
SELECT
  customerID,
  gender,
  senior_citizen_flag,
  partner_flag,
  dependents_flag,
  tenure,
  phone_service_flag,
  MultipleLines,
  InternetService,
  OnlineSecurity,
  OnlineBackup,
  DeviceProtection,
  TechSupport,
  StreamingTV,
  StreamingMovies,
  Contract,
  paperless_billing_flag,
  PaymentMethod,
  MonthlyCharges,
  total_charges,
  churn_flag
FROM `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`;
