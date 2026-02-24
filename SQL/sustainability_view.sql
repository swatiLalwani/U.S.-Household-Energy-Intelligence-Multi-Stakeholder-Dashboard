-- ============================================================
-- FILE: 06_sustainability_view.sql
-- PURPOSE: Sustainability Dashboard data view
-- Audience: ESG Teams, Sustainability Analysts, Policy Researchers
-- Key Questions:
--   - What is the total CO2 footprint of US households?
--   - Which housing types generate the most emissions?
--   - Does higher income correlate with higher per-capita energy use?
--   - Which states have the highest residential CO2?
-- CO2 Factor: 0.386 kg/kWh (EPA 2020 US grid average)
-- Output: sustainability_view → export as sustainability_view.csv
-- ============================================================

USE recs2020;
GO

DROP TABLE IF EXISTS sustainability_view;
GO

SELECT
    DOEID,

    -- Geography
    REGIONC                                                                         AS region,
    STATE_FIPS,
    state_name,
    state_postal,

    -- Income Bracket
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
    END                                                                             AS income_bracket,

    -- Housing Type
    CASE TRY_CAST(TYPEHUQ AS INT)
        WHEN 1 THEN 'Mobile Home'
        WHEN 2 THEN 'Single Family Detached'
        WHEN 3 THEN 'Single Family Attached'
        WHEN 4 THEN 'Apartment (2-4 units)'
        WHEN 5 THEN 'Apartment (5+ units)'
    END                                                                             AS housing_type,

    -- Core Metrics
    TRY_CAST(TOTSQFT_EN AS FLOAT)                                                  AS home_sqft,
    TRY_CAST(NHSLDMEM AS INT)                                                      AS household_members,
    TRY_CAST(KWHIN AS FLOAT)                                                       AS total_kwh,

    -- CO2 Emissions (EPA 2020 US average grid emission factor: 0.386 kg/kWh)
    ROUND(TRY_CAST(KWHIN AS FLOAT) * 0.386, 2)                                    AS co2_kg,
    ROUND(TRY_CAST(KWHIN AS FLOAT) * 0.386 / 1000, 3)                            AS co2_tonnes,

    -- Energy Intensity Metrics
    ROUND(TRY_CAST(KWHIN AS FLOAT) / NULLIF(TRY_CAST(TOTSQFT_EN AS FLOAT),0), 2) AS kwh_per_sqft,
    ROUND(TRY_CAST(KWHIN AS FLOAT) / NULLIF(TRY_CAST(NHSLDMEM AS FLOAT),0), 2)   AS kwh_per_person,

    -- Total Energy (All Fuels Combined in BTU)
    ROUND(
        TRY_CAST(BTUEL   AS FLOAT) + TRY_CAST(BTUNG AS FLOAT) +
        TRY_CAST(BTUFO   AS FLOAT) + TRY_CAST(BTULP AS FLOAT) +
        TRY_CAST(BTUWOOD AS FLOAT)
    , 0)                                                                            AS total_btu_all_fuels,

    -- Fuel Mix Flags (Yes/No)
    CASE WHEN TRY_CAST(BTUNG   AS FLOAT) > 0 THEN 'Yes' ELSE 'No' END             AS uses_gas,
    CASE WHEN TRY_CAST(BTUFO   AS FLOAT) > 0 THEN 'Yes' ELSE 'No' END             AS uses_fuel_oil,
    CASE WHEN TRY_CAST(BTULP   AS FLOAT) > 0 THEN 'Yes' ELSE 'No' END             AS uses_propane,
    CASE WHEN TRY_CAST(BTUWOOD AS FLOAT) > 0 THEN 'Yes' ELSE 'No' END             AS uses_wood,

    -- Cost Metrics
    TRY_CAST(DOLLAREL AS FLOAT)                                                    AS electricity_cost_usd,
    ROUND(
        TRY_CAST(DOLLAREL AS FLOAT) + TRY_CAST(DOLLARNG AS FLOAT) +
        TRY_CAST(DOLLARFO AS FLOAT) + TRY_CAST(DOLLARLP AS FLOAT)
    , 2)                                                                            AS total_energy_cost_usd

INTO sustainability_view
FROM recs_clean
WHERE TRY_CAST(KWHIN AS FLOAT) > 0;
GO

-- Verify & preview
SELECT COUNT(*) AS sustainability_rows FROM sustainability_view;
-- Expected: 18,477

SELECT TOP 5 * FROM sustainability_view;
GO
