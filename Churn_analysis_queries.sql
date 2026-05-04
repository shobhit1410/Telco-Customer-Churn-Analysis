--Query 1 — Churn Rate by Contract Type & Payment Method

SELECT
    Contract,
    PaymentMethod,
    COUNT(*)AS total_customers,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)AS churned,
    ROUND(SUM(CASE WHEN Churn = 1 THEN 1.0 ELSE 0 END)
          / COUNT(*) * 100, 2)AS churn_rate_pct
FROM churn
GROUP BY ROLLUP(Contract, PaymentMethod)
ORDER BY Contract, churn_rate_pct DESC;

--Query 2 — Revenue at Risk by Internet Service Type
WITH revenue_summary AS (
    SELECT
        InternetService,
        MonthlyCharges,
        TotalCharges,
        Churn,
        SUM(MonthlyCharges) OVER (PARTITION BY InternetService)AS total_monthly_by_service,
        SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END)
            OVER (PARTITION BY InternetService)AS monthly_revenue_at_risk
    FROM churn
)
SELECT
    InternetService,
    COUNT(*)AS total_customers,
    ROUND(MAX(total_monthly_by_service), 2)AS total_monthly_revenue,
    ROUND(MAX(monthly_revenue_at_risk), 2)AS revenue_at_risk,
    ROUND(MAX(monthly_revenue_at_risk)
          / MAX(total_monthly_by_service) * 100, 2)AS pct_revenue_at_risk
FROM revenue_summary
GROUP BY InternetService
ORDER BY pct_revenue_at_risk DESC;

--Query 3 — Customer Lifetime Value vs Churn
WITH ltv_bands AS (
    SELECT
        customerID,
        Contract,
        TotalCharges,
        MonthlyCharges,
        tenure,
        Churn,
        NTILE(4) OVER (ORDER BY TotalCharges DESC)                       AS ltv_quartile
    FROM churn
    WHERE TotalCharges > 0
)
SELECT
    CASE ltv_quartile
        WHEN 1 THEN 'Q1 — Highest Value'
        WHEN 2 THEN 'Q2 — Upper Mid'
        WHEN 3 THEN 'Q3 — Lower Mid'
        WHEN 4 THEN 'Q4 — Lowest Value'
    END AS customer_segment,
    COUNT(*)AS total_customers,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)AS churned,
    ROUND(AVG(TotalCharges), 2)AS avg_lifetime_value,
    ROUND(AVG(CAST(tenure AS FLOAT)), 1)AS avg_tenure_months,
    ROUND(SUM(CASE WHEN Churn = 1 THEN 1.0 ELSE 0 END)
          / COUNT(*) * 100, 2)AS churn_rate_pct
FROM ltv_bands
GROUP BY ltv_quartile
ORDER BY ltv_quartile;

--Query 4 — Composite Churn Risk Score

WITH risk_scoring AS (
    SELECT
        customerID,gender,SeniorCitizen,Contract,tenure,MonthlyCharges,InternetService,Churn,
        (CASE WHEN Contract = 'Month-to-month'   THEN 3
              WHEN Contract = 'One year'          THEN 2
              ELSE 1 END)
      + (CASE WHEN tenure <= 12                  THEN 3
              WHEN tenure <= 24                  THEN 2
              ELSE 1 END)
      + (CASE WHEN InternetService = 'Fiber optic' THEN 3
              WHEN InternetService = 'DSL'          THEN 2
              ELSE 1 END)
      + (CASE WHEN MonthlyCharges >= 70           THEN 3
              WHEN MonthlyCharges >= 40           THEN 2
              ELSE 1 END)
      + (CASE WHEN SeniorCitizen = 1              THEN 2
              ELSE 1 END)AS risk_score
    FROM churn
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (ORDER BY risk_score DESC)AS risk_rank
    FROM risk_scoring
    WHERE Churn = 0
)
SELECT
    customerID, gender, SeniorCitizen, Contract,
    tenure, MonthlyCharges, InternetService,
    risk_score, risk_rank
FROM ranked
WHERE risk_rank <= 15
ORDER BY risk_rank;

--Query 5 — Add-on Service Adoption vs Churn

SELECT
    InternetService,
    ROUND(AVG(CAST(OnlineSecurity   AS FLOAT)) * 100, 1)AS pct_online_security,
    ROUND(AVG(CAST(OnlineBackup     AS FLOAT)) * 100, 1)AS pct_online_backup,
    ROUND(AVG(CAST(DeviceProtection AS FLOAT)) * 100, 1)AS pct_device_protection,
    ROUND(AVG(CAST(TechSupport      AS FLOAT)) * 100, 1)AS pct_tech_support,
    ROUND(AVG(CAST(StreamingTV      AS FLOAT)) * 100, 1)AS pct_streaming_tv,
    ROUND(AVG(CAST(StreamingMovies  AS FLOAT)) * 100, 1)AS pct_streaming_movies,
    COUNT(*)AS total_customers,
    ROUND(AVG(CAST(Churn AS FLOAT)) * 100, 1)AS churn_rate_pct
FROM churn
WHERE InternetService != 'No'
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

--Query 6 — Tenure Cohort Retention with Running Average
WITH cohorts AS (
    SELECT
        CASE
            WHEN tenure BETWEEN 0  AND 12 THEN '01 — 0-12 Months'
            WHEN tenure BETWEEN 13 AND 24 THEN '02 — 13-24 Months'
            WHEN tenure BETWEEN 25 AND 36 THEN '03 — 25-36 Months'
            WHEN tenure BETWEEN 37 AND 48 THEN '04 — 37-48 Months'
            WHEN tenure BETWEEN 49 AND 60 THEN '05 — 49-60 Months'
            ELSE                               '06 — 60+ Months'
        END AS tenure_cohort,
        Churn
    FROM churn
),
cohort_stats AS (
    SELECT
        tenure_cohort,
        COUNT(*)AS total,
        SUM(CASE WHEN Churn = 0 THEN 1 ELSE 0 END)AS retained,
        SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)AS churned
    FROM cohorts
    GROUP BY tenure_cohort
)
SELECT
    tenure_cohort,
    total,
    retained,
    churned,
    ROUND(retained * 100.0 / total, 2)AS retention_rate_pct,
    ROUND(churned  * 100.0 / total, 2)AS churn_rate_pct,
    ROUND(AVG(retained * 100.0 / total)
          OVER (ORDER BY tenure_cohort
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW), 2)AS running_avg_retention_pct
FROM cohort_stats
ORDER BY tenure_cohort;

--Query 7 — Executive KPI Summary
SELECT 'Total Customers'                          AS metric,
        CAST(COUNT(*) AS NVARCHAR)                AS value
FROM churn

UNION ALL

SELECT 'Total Churned',
        CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS NVARCHAR)
FROM churn

UNION ALL

SELECT 'Overall Churn Rate %',
        CAST(ROUND(AVG(CAST(Churn AS FLOAT)) * 100, 2) AS NVARCHAR)
FROM churn

UNION ALL

SELECT 'Avg Monthly Charges ($)',
        CAST(ROUND(AVG(MonthlyCharges), 2) AS NVARCHAR)
FROM churn

UNION ALL

SELECT 'Monthly Revenue at Risk ($)',
        CAST(ROUND(SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END), 2) AS NVARCHAR)
FROM churn

UNION ALL

SELECT 'Avg Tenure of Churned Customers (months)',
        CAST(ROUND(AVG(CASE WHEN Churn = 1 THEN CAST(tenure AS FLOAT) END), 1) AS NVARCHAR)
FROM churn

UNION ALL

SELECT 'Senior Citizen Churn Rate %',
        CAST(ROUND(
            SUM(CASE WHEN Churn = 1 AND SeniorCitizen = 1 THEN 1.0 ELSE 0 END)
            / NULLIF(SUM(CAST(SeniorCitizen AS FLOAT)), 0) * 100
        , 2) AS NVARCHAR)
FROM churn;
