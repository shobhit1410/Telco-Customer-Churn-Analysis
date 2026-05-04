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
<img width="561" height="350" alt="Query 1" src="https://github.com/user-attachments/assets/bce4078c-fb1c-4c03-8029-eaff6b45d67d" />

| 2 | Which internet service type puts the most monthly revenue at risk? |
<img width="745" height="181" alt="Query 2" src="https://github.com/user-attachments/assets/2030fce9-6536-41c3-a589-5995a4e104a4" />

| 3 | Are high-value customers churning more or less than low-value ones? |
<img width="789" height="236" alt="Query 3" src="https://github.com/user-attachments/assets/66976652-5fb5-4c02-924c-cb5cd142cf72" />

| 4 | Which currently active customers are at highest risk of churning? |
<img width="792" height="817" alt="Query 4" src="https://github.com/user-attachments/assets/25fb8e1d-42b0-4e82-b242-1790bdf73e91" />

| 5 | Do customers with more add-on services churn less? |
<img width="1096" height="281" alt="Query 5" src="https://github.com/user-attachments/assets/8eb4b25d-8099-4db2-a245-a38bcba584ac" />

| 6 | At which stage of the customer lifecycle is churn the highest? |
<img width="795" height="240" alt="Query 6" src="https://github.com/user-attachments/assets/2d9b14ae-c100-4060-b32e-ab467bfbace8" />

| 7 | What does the overall business health look like at a glance? |
<img width="479" height="263" alt="Query 7" src="https://github.com/user-attachments/assets/6036e319-32b5-4436-acfb-a3ee29311714" />


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


 
