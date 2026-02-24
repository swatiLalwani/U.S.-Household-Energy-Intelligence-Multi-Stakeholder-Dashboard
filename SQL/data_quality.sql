-- ============================================================
-- FILE: 02_data_quality_check.sql
-- PURPOSE: Assess data quality before cleaning
-- Run this BEFORE creating the clean table
-- ============================================================

USE recs2020;
GO

-- ── 1. Row Count ─────────────────────────────────────────────
SELECT COUNT(*) AS total_rows FROM recs_main;
-- Expected: 18,496

-- ── 2. NULL & Invalid Value Check ────────────────────────────
SELECT
    COUNT(*)                                                        AS total_rows,

    -- NULL checks
    SUM(CASE WHEN KWHIN    IS NULL THEN 1 ELSE 0 END)              AS null_kwh,
    SUM(CASE WHEN DOLLAREL IS NULL THEN 1 ELSE 0 END)              AS null_dollarel,
    SUM(CASE WHEN TOTSQFT_EN IS NULL THEN 1 ELSE 0 END)           AS null_sqft,
    SUM(CASE WHEN NHSLDMEM IS NULL THEN 1 ELSE 0 END)              AS null_members,
    SUM(CASE WHEN REGIONC  IS NULL THEN 1 ELSE 0 END)              AS null_region,
    SUM(CASE WHEN state_name IS NULL THEN 1 ELSE 0 END)            AS null_state,
    SUM(CASE WHEN TYPEHUQ  IS NULL THEN 1 ELSE 0 END)              AS null_housing,
    SUM(CASE WHEN MONEYPY  IS NULL THEN 1 ELSE 0 END)              AS null_income,
    SUM(CASE WHEN FUELHEAT IS NULL THEN 1 ELSE 0 END)              AS null_fuelheat,
    SUM(CASE WHEN ACEQUIPM_PUB IS NULL THEN 1 ELSE 0 END)         AS null_cooling,

    -- Invalid numeric values (stored as VARCHAR but non-convertible)
    SUM(CASE WHEN TRY_CAST(KWHIN AS FLOAT) IS NULL
             AND KWHIN IS NOT NULL THEN 1 ELSE 0 END)              AS invalid_kwh,

    -- Zero / negative values
    SUM(CASE WHEN TRY_CAST(KWHIN AS FLOAT) <= 0
             THEN 1 ELSE 0 END)                                    AS zero_neg_kwh,
    SUM(CASE WHEN TRY_CAST(DOLLAREL AS FLOAT) <= 0
             THEN 1 ELSE 0 END)                                    AS zero_dollarel,
    SUM(CASE WHEN TRY_CAST(TOTSQFT_EN AS FLOAT) <= 0
             THEN 1 ELSE 0 END)                                    AS zero_sqft,

    -- Outlier check
    MAX(TRY_CAST(KWHIN AS FLOAT))                                  AS max_kwh,
    MIN(TRY_CAST(KWHIN AS FLOAT))                                  AS min_kwh,
    AVG(TRY_CAST(KWHIN AS FLOAT))                                  AS avg_kwh,
    MAX(TRY_CAST(DOLLAREL AS FLOAT))                               AS max_dollarel,
    AVG(TRY_CAST(DOLLAREL AS FLOAT))                               AS avg_dollarel,
    MAX(TRY_CAST(TOTSQFT_EN AS FLOAT))                            AS max_sqft,
    MIN(TRY_CAST(TOTSQFT_EN AS FLOAT))                            AS min_sqft

FROM recs_main;

-- ── 3. Inspect Extreme KWH Outliers ──────────────────────────
-- Findings: 4 households with KWH > 100,000 (avg is ~10,849)
-- These are 9-17x the average — likely meter errors
SELECT
    DOEID, REGIONC, state_name, TYPEHUQ,
    TOTSQFT_EN, NHSLDMEM, MONEYPY,
    KWHIN, DOLLAREL
FROM recs_main
WHERE TRY_CAST(KWHIN AS FLOAT) > 100000
ORDER BY TRY_CAST(KWHIN AS FLOAT) DESC;

-- ── 4. Check Distinct Values for Key Dimension Columns ───────
SELECT DISTINCT REGIONC   FROM recs_main ORDER BY REGIONC;
SELECT DISTINCT TYPEHUQ   FROM recs_main ORDER BY TYPEHUQ;
SELECT DISTINCT MONEYPY   FROM recs_main ORDER BY TRY_CAST(MONEYPY AS INT);
SELECT DISTINCT FUELHEAT  FROM recs_main ORDER BY TRY_CAST(FUELHEAT AS INT);
SELECT DISTINCT ACEQUIPM_PUB FROM recs_main ORDER BY TRY_CAST(ACEQUIPM_PUB AS INT);
SELECT DISTINCT DWASHUSE  FROM recs_main ORDER BY TRY_CAST(DWASHUSE AS INT);

-- ── Quality Summary ───────────────────────────────────────────
-- Results:
--   total_rows      : 18,496
--   null_kwh        : 0       ✅
--   null_dollarel   : 0       ✅
--   zero_dollarel   : 15      ⚠️ → Excluded in clean table
--   KWH > 100,000   : 4       ⚠️ → Excluded in clean table
--   Final clean rows: 18,477
