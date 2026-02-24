-- ============================================================
-- FILE: 05_operations_view.sql
-- PURPOSE: Operations Dashboard data view
-- Audience: Energy Managers, Facility Operators
-- Key Questions:
--   - Which appliances drive the most energy consumption?
--   - What is the dominant heating and cooling equipment type?
--   - How does home size correlate with energy use?
--   - What % of energy goes to AC vs heating vs other?
-- Output: operations_view table → export as operations_view.csv
-- ============================================================

USE recs2020;
GO

DROP TABLE IF EXISTS operations_view;
GO

SELECT
    DOEID,

    -- Geography
    REGIONC                                                                         AS region,
    state_name,
    state_postal,

    -- Housing Type
    CASE TRY_CAST(TYPEHUQ AS INT)
        WHEN 1 THEN 'Mobile Home'
        WHEN 2 THEN 'Single Family Detached'
        WHEN 3 THEN 'Single Family Attached'
        WHEN 4 THEN 'Apartment (2-4 units)'
        WHEN 5 THEN 'Apartment (5+ units)'
    END                                                                             AS housing_type,

    -- End-Use Electricity Breakdown (kWh)
    TRY_CAST(KWHCOL AS FLOAT)                                                      AS ac_kwh,
    TRY_CAST(KWHSPH AS FLOAT)                                                      AS heating_kwh,
    TRY_CAST(KWHWTH AS FLOAT)                                                      AS water_heating_kwh,
    TRY_CAST(KWHOTH AS FLOAT)                                                      AS other_kwh,
    TRY_CAST(KWHIN  AS FLOAT)                                                      AS total_kwh,

    -- Cooling Equipment Type
    CASE TRY_CAST(ACEQUIPM_PUB AS INT)
        WHEN 1 THEN 'Central AC'
        WHEN 2 THEN 'Window/Wall Units'
        WHEN 3 THEN 'Both'
        WHEN 4 THEN 'None'
    END                                                                             AS cooling_type,

    -- Heating Fuel Type
    CASE TRY_CAST(FUELHEAT AS INT)
        WHEN 1  THEN 'Natural Gas'
        WHEN 2  THEN 'Propane'
        WHEN 3  THEN 'Fuel Oil'
        WHEN 5  THEN 'Electricity'
        WHEN 7  THEN 'Wood'
        WHEN 21 THEN 'No Heat'
    END                                                                             AS heating_fuel,

    -- Appliances
    TRY_CAST(NUMCFAN AS INT)                                                       AS ceiling_fans,
    TRY_CAST(NUMFRIG AS INT)                                                       AS refrigerators,

    -- Dishwasher Usage Frequency
    CASE TRY_CAST(DWASHUSE AS INT)
        WHEN 0 THEN 'No Dishwasher'
        WHEN 1 THEN 'Less than once/week'
        WHEN 2 THEN '1-3 times/week'
        WHEN 3 THEN '4-6 times/week'
        WHEN 4 THEN 'Once a day'
        WHEN 5 THEN 'More than once/day'
    END                                                                             AS dishwasher_frequency,

    -- Home Characteristics
    TRY_CAST(TOTSQFT_EN AS FLOAT)                                                  AS home_sqft,
    TRY_CAST(NHSLDMEM AS INT)                                                      AS household_members,

    -- Calculated: % of total electricity per end-use
    ROUND(TRY_CAST(KWHCOL AS FLOAT) / NULLIF(TRY_CAST(KWHIN AS FLOAT),0) * 100, 1) AS pct_ac,
    ROUND(TRY_CAST(KWHSPH AS FLOAT) / NULLIF(TRY_CAST(KWHIN AS FLOAT),0) * 100, 1) AS pct_heating,
    ROUND(TRY_CAST(KWHWTH AS FLOAT) / NULLIF(TRY_CAST(KWHIN AS FLOAT),0) * 100, 1) AS pct_water_heating,
    ROUND(TRY_CAST(KWHOTH AS FLOAT) / NULLIF(TRY_CAST(KWHIN AS FLOAT),0) * 100, 1) AS pct_other

INTO operations_view
FROM recs_clean
WHERE TRY_CAST(KWHIN AS FLOAT) > 0
  AND TRY_CAST(FUELHEAT AS INT) IN (1,2,3,5,7,21)       -- Exclude NULL heating fuel
  AND TRY_CAST(ACEQUIPM_PUB AS INT) IN (1,2,3,4);        -- Exclude NULL cooling type
GO

-- Verify & preview
SELECT COUNT(*) AS operations_rows FROM operations_view;

SELECT TOP 5 * FROM operations_view;
GO
