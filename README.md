# Telco-Customer-Churn-Analysis


## Overview
An end-to-end SQL analytics project analysing customer churn 
behaviour for a telecom company using the publicly available 
Telco Customer Churn dataset (7,043 customers, 21 features).

The goal was to identify churn patterns, quantify revenue at 
risk, and surface high-risk active customers — answering real 
business questions a retention or CRM analyst would face.

---

## Dataset
- Source: [Kaggle — Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
- Rows: 7,043 customers
- Columns: 21 (demographics, services subscribed, 
  contract info, charges, churn status)
- Tool: Microsoft SQL Server

---

## Business Questions Answered

| # | Business Question |
|---|---|
| 1 | Which contract type and payment method has the highest churn rate? |
| 2 | Which internet service type puts the most monthly revenue at risk? |
| 3 | Are high-value customers churning more or less than low-value ones? |
| 4 | Which currently active customers are at highest risk of churning? |
| 5 | Do customers with more add-on services churn less? |
| 6 | At which stage of the customer lifecycle is churn the highest? |
| 7 | What does the overall business health look like at a glance? |

---

## SQL Concepts Used
- Common Table Expressions (CTEs)
- Window Functions — `SUM() OVER`, `AVG() OVER`, `NTILE()`, 
  `DENSE_RANK()`
- `ROLLUP` for subtotals and grand totals
- Conditional aggregation — `SUM(CASE WHEN ... END)`
- Framed windows — `ROWS BETWEEN UNBOUNDED PRECEDING 
  AND CURRENT ROW`
- `NULLIF` for divide-by-zero protection
- `UNION ALL` for KPI dashboard queries
- Multi-factor composite scoring with weighted `CASE WHEN`

---

## Key Findings
- Month-to-month contract customers churn at ~43% vs only 
  ~11% for two-year contracts
- Fiber optic internet service has the highest monthly revenue 
  at risk despite being the premium tier
- Customers in their first 12 months have the highest churn 
  rate — early retention is critical
- Senior citizens churn at a disproportionately higher rate 
  compared to their share of the customer base
- Customers with no add-on services (security, backup, 
  support) churn significantly more


 
