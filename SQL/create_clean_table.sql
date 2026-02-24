-- ============================================================
-- FILE: 03_create_clean_table.sql
-- PURPOSE: Create recs_clean — filtered, analysis-ready table
-- Removes: 15 zero-cost rows + 4 extreme KWH outliers
-- Output:  18,477 clean rows
-- ============================================================

USE recs2020;
GO

DROP TABLE IF EXISTS recs_clean;
GO

SELECT *
INTO recs_clean
FROM recs_main
WHERE
    -- Remove 15 households with $0 electricity cost (unreliable)
    TRY_CAST(DOLLAREL AS FLOAT) > 0

    -- Remove 4 extreme KWH outliers (9-17x the average of 10,849 kWh)
    AND TRY_CAST(KWHIN AS FLOAT) BETWEEN 42 AND 100000

    -- Remove any zero sqft records
    AND TRY_CAST(TOTSQFT_EN AS FLOAT) > 0;
GO

-- Verify
SELECT COUNT(*) AS clean_rows FROM recs_clean;
-- Expected: 18,477
GO
