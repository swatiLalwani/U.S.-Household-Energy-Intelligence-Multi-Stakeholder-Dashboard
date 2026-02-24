-- ============================================================
-- FILE: 04_executive_view.sql
-- PURPOSE: Executive Dashboard data view
-- Audience: C-Suite, VP Finance, Budget Owners
-- Key Questions:
--   - How much are we spending on energy by region?
--   - Which income brackets drive the highest energy costs?
--   - What is our national energy intensity (kWh/sqft)?
-- Output: executive_view table → export as executive_view.csv
-- ============================================================

USE recs2020;
GO

DROP TABLE IF EXISTS executive_view;
GO

SELECT
    DOEID,

    -- Geography
    REGIONC                                                                     AS region,
    state_name,
    state_postal,

    -- Housing & Demographics
    CASE TRY_CAST(TYPEHUQ AS INT)
        WHEN 1 THEN 'Mobile Home'
        WHEN 2 THEN 'Single Family Detached'
        WHEN 3 THEN 'Single Family Attached'
        WHEN 4 THEN 'Apartment (2-4 units)'
        WHEN 5 THEN 'Apartment (5+ units)'
    END                                                                         AS housing_type,

    -- Income Bracket (16 levels per RECS codebook)
    CASE TRY_CAST(MONEYPY AS INT)
        WHEN 1  THEN 'Under $20K'
        WHEN 2  THEN '$20K-$40K'
        WHEN 3  THEN '$40K-$60K'
        WHEN 4  THEN '$60K-$80K'
        WHEN 5  THEN '$80K-$100K'
        WHEN 6  THEN '$100K-$120K'
        WHEN 7  THEN '$120K-$140K'
        WHEN 8  THEN '$140K-$160K'
        WHEN 9  THEN '$160K-$180K'
        WHEN 10 THEN '$180K-$200K'
        WHEN 11 THEN '$200K-$250K'
        WHEN 12 THEN '$250K-$300K'
        WHEN 13 THEN '$300K-$350K'
        WHEN 14 THEN '$350K-$400K'
        WHEN 15 THEN '$400K-$450K'
        WHEN 16 THEN '$450K+'
    END                                                                         AS income_bracket,

    -- Core Metrics
    TRY_CAST(TOTSQFT_EN AS FLOAT)                                              AS home_sqft,
    TRY_CAST(NHSLDMEM AS INT)                                                  AS household_members,
    TRY_CAST(KWHIN AS FLOAT)                                                   AS total_kwh,
    TRY_CAST(DOLLAREL AS FLOAT)                                                AS electricity_cost_usd,
    TRY_CAST(DOLLARNG AS FLOAT)                                                AS gas_cost_usd,

    -- Calculated: Total cost across all fuel types
    ROUND(
        TRY_CAST(DOLLAREL AS FLOAT) + TRY_CAST(DOLLARNG AS FLOAT) +
        TRY_CAST(DOLLARFO AS FLOAT) + TRY_CAST(DOLLARLP AS FLOAT)
    , 2)                                                                        AS total_energy_cost_usd,

    -- Calculated: Energy intensity (efficiency benchmark)
    ROUND(
        TRY_CAST(KWHIN AS FLOAT) / NULLIF(TRY_CAST(TOTSQFT_EN AS FLOAT), 0)
    , 2)                                                                        AS kwh_per_sqft

INTO executive_view
FROM recs_clean
WHERE TRY_CAST(KWHIN AS FLOAT) > 0
  AND TRY_CAST(DOLLAREL AS FLOAT) > 0;
GO

-- Verify & preview
SELECT COUNT(*) AS executive_rows FROM executive_view;
-- Expected: 18,477

SELECT TOP 5 * FROM executive_view;
GO
