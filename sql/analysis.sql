-- PostgreSQL schema for the source CSV. Column order matches the CSV.
CREATE TABLE IF NOT EXISTS campaigns (
    ad_group TEXT,
    month VARCHAR(20),
    impressions INTEGER,
    clicks INTEGER,
    ctr NUMERIC(10,4),
    conversions INTEGER,
    conv_rate NUMERIC(10,4),
    cost NUMERIC(12,2),
    cpc NUMERIC(10,4),
    revenue NUMERIC(12,2),
    sale_amount NUMERIC(15,2),
    profit_loss NUMERIC(15,3)
);

-- Use pgAdmin Import/Export Data on campaigns to import data/final_shop_6modata.csv.
-- Select: Import, CSV, Header = Yes, delimiter = comma, UTF-8.
-- Do not re-import twice without clearing the existing rows.

-- Source validation
SELECT COUNT(*) AS rows, COUNT(DISTINCT ad_group) AS unique_ad_groups
FROM campaigns;

-- Overall metrics. Always compute rates from aggregated numerators and denominators.
SELECT
    SUM(revenue) AS total_revenue,
    SUM(cost) AS total_cost,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(clicks)::numeric / NULLIF(SUM(impressions), 0) * 100, 2) AS ctr_pct,
    ROUND(SUM(cost) / NULLIF(SUM(clicks), 0), 2) AS cpc,
    ROUND(SUM(cost) / NULLIF(SUM(conversions), 0), 2) AS cpa,
    ROUND(SUM(revenue) / NULLIF(SUM(cost), 0), 2) AS roas
FROM campaigns;

-- Monthly performance, sorted chronologically
SELECT
    month,
    SUM(cost) AS total_cost,
    SUM(revenue) AS total_revenue,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(revenue) / NULLIF(SUM(cost), 0), 2) AS roas,
    ROUND(SUM(cost) / NULLIF(SUM(conversions), 0), 2) AS cpa
FROM campaigns
GROUP BY month
ORDER BY CASE month
    WHEN 'July' THEN 7
    WHEN 'August' THEN 8
    WHEN 'September' THEN 9
    WHEN 'October' THEN 10
    WHEN 'November' THEN 11
    ELSE 99 END;

-- Ad group performance
SELECT
    ad_group,
    SUM(revenue) AS total_revenue,
    SUM(cost) AS total_cost,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(revenue) / NULLIF(SUM(cost), 0), 2) AS roas,
    ROUND(SUM(cost) / NULLIF(SUM(conversions), 0), 2) AS cpa
FROM campaigns
GROUP BY ad_group
ORDER BY total_revenue DESC;

-- Top ten ad groups by revenue
SELECT ad_group, SUM(revenue) AS total_revenue
FROM campaigns
GROUP BY ad_group
ORDER BY total_revenue DESC
LIMIT 10;
