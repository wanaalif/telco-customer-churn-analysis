# Data Dictionary

**Source:** [Telco Customer Churn (IBM sample data, via Kaggle)](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
**Grain:** one row per customer (7,043 rows, 21 source columns)
**Typed table:** `telco-customer-churn-488312.telco_customer_churn.Telcom Customer Churn Typed`
(built in [`sql/01_data_cleaning.sql`](../sql/01_data_cleaning.sql))

## Column reference

| Typed column | Source column | Type | Description | Values / notes |
|---|---|---|---|---|
| `customerID` | customerID | STRING | Unique customer identifier | Primary key, no duplicates |
| `gender` | gender | STRING | Customer gender | Male, Female |
| `senior_citizen_flag` | SeniorCitizen | INT64 | Customer is a senior citizen | 1 = yes, 0 = no |
| `partner_flag` | Partner | INT64 | Customer has a partner | 1 = yes, 0 = no |
| `dependents_flag` | Dependents | INT64 | Customer has dependents | 1 = yes, 0 = no |
| `tenure` | tenure | INT64 | Months the customer has stayed with the company | 0 to 72 |
| `phone_service_flag` | PhoneService | INT64 | Has phone service | 1 = yes, 0 = no |
| `MultipleLines` | MultipleLines | STRING | Has multiple phone lines | Yes, No, No phone service |
| `InternetService` | InternetService | STRING | Internet service provider type | DSL, Fiber optic, No |
| `OnlineSecurity` | OnlineSecurity | STRING | Has online security add-on | Yes, No, No internet service |
| `OnlineBackup` | OnlineBackup | STRING | Has online backup add-on | Yes, No, No internet service |
| `DeviceProtection` | DeviceProtection | STRING | Has device protection add-on | Yes, No, No internet service |
| `TechSupport` | TechSupport | STRING | Has tech support add-on | Yes, No, No internet service |
| `StreamingTV` | StreamingTV | STRING | Streams TV through the service | Yes, No, No internet service |
| `StreamingMovies` | StreamingMovies | STRING | Streams movies through the service | Yes, No, No internet service |
| `Contract` | Contract | STRING | Contract term | Month-to-month, One year, Two year |
| `paperless_billing_flag` | PaperlessBilling | INT64 | Uses paperless billing | 1 = yes, 0 = no |
| `PaymentMethod` | PaymentMethod | STRING | How the customer pays | Electronic check, Mailed check, Bank transfer (automatic), Credit card (automatic) |
| `MonthlyCharges` | MonthlyCharges | FLOAT64 | Amount charged each month | Currency units as provided in the dataset |
| `total_charges` | TotalCharges | FLOAT64 | Total amount charged over the customer's lifetime | Converted from text; see cleaning notes |
| `churn_flag` | Churn | INT64 | Customer left within the last month | 1 = churned, 0 = retained (target variable) |

## Cleaning notes

- **No duplicates:** `customerID` is unique across all rows.
- **`TotalCharges` stored as text:** the source column contains blank strings for customers with `tenure = 0` (new accounts that have not been billed). These are set to `0.0` and the rest are converted with `SAFE_CAST` to FLOAT64.
- **Flags:** Yes/No columns are converted to 1/0 integers so they can be averaged and summed directly (for example, `AVG(churn_flag)` gives the churn rate).
- **Null handling:** the null check found no missing values in the flag columns; `IFNULL(..., 0)` is a defensive default so future loads cannot produce NULL flags. If new data has real gaps, revisit this assumption rather than treating NULL as "No".
- **Service columns are left as text** because they carry three states ("No internet service" and "No phone service" are different from "No").

## Dashboard calculated fields (Looker Studio)

| Field | Definition | Purpose |
|---|---|---|
| `churn_status` | `CASE WHEN churn_flag = 1 THEN 'Churned' WHEN churn_flag = 0 THEN 'Retained' ELSE 'Unknown' END` | Readable label for charts and legends |
| `tenure_year_group` | 12-month buckets on `tenure`: 0-1 Year (≤12), 1-2 Years (≤24), 2-3 Years (≤36), 3-4 Years (≤48), 4-5 Years (≤60), 5+ Years | Retention by customer lifetime |
| `churn_rate` | `AVG(churn_flag)` | Share of customers who churned |
| `total_revenue_lost` (Total MRR Lost) | `SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges ELSE 0 END)` | Monthly recurring revenue lost to churned customers |

> **Note on "MRR lost":** this is the *monthly* revenue those customers were paying, not their lifetime value.
