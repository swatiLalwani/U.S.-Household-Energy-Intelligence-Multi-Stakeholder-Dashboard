-- ============================================================
-- FILE: 01_create_staging.sql
-- PURPOSE: Create recs_main staging table in SQL Server
-- NOTE: CSV loaded via Python script (see /python/load_recs.py)
--       due to SSMS Import Flat File limitation on 600+ columns
-- ============================================================

CREATE DATABASE recs2020;
GO

USE recs2020;
GO

-- Drop if exists from previous run
DROP TABLE IF EXISTS recs_main;
GO

-- All columns stored as VARCHAR to handle mixed types in raw CSV
-- TRY_CAST used in transformation queries for safe type conversion
CREATE TABLE recs_main (
    DOEID           VARCHAR(20),
    REGIONC         VARCHAR(20),
    DIVISION        VARCHAR(50),
    STATE_FIPS      VARCHAR(10),
    state_postal    VARCHAR(5),
    state_name      VARCHAR(50),
    BA_climate      VARCHAR(50),
    IECC_climate_code VARCHAR(10),
    TYPEHUQ         VARCHAR(10),
    TOTSQFT_EN      VARCHAR(20),
    TOTHSQFT        VARCHAR(20),
    NHSLDMEM        VARCHAR(10),
    MONEYPY         VARCHAR(10),
    HHAGE           VARCHAR(10),
    EMPLOYHH        VARCHAR(10),
    KWHIN           VARCHAR(20),   -- Total electricity (kWh)
    KWHCOL          VARCHAR(20),   -- AC electricity (kWh)
    KWHSPH          VARCHAR(20),   -- Space heating electricity (kWh)
    KWHWTH          VARCHAR(20),   -- Water heating electricity (kWh)
    KWHOTH          VARCHAR(20),   -- Other electricity (kWh)
    DOLLAREL        VARCHAR(20),   -- Annual electricity cost ($)
    DOLLARNG        VARCHAR(20),   -- Annual natural gas cost ($)
    DOLLARFO        VARCHAR(20),   -- Annual fuel oil cost ($)
    DOLLARLP        VARCHAR(20),   -- Annual propane cost ($)
    BTUEL           VARCHAR(20),   -- Electricity (BTU)
    BTUNG           VARCHAR(20),   -- Natural gas (BTU)
    BTUFO           VARCHAR(20),   -- Fuel oil (BTU)
    BTULP           VARCHAR(20),   -- Propane (BTU)
    BTUWOOD         VARCHAR(20),   -- Wood (BTU)
    ACEQUIPM_PUB    VARCHAR(10),   -- AC equipment type
    ACEQUIPAGE      VARCHAR(10),   -- AC equipment age
    FUELHEAT        VARCHAR(10),   -- Primary heating fuel
    EQUIPAGE        VARCHAR(10),   -- Heating equipment age
    NUMCFAN         VARCHAR(10),   -- Number of ceiling fans
    NUMFRIG         VARCHAR(10),   -- Number of refrigerators
    DWASHUSE        VARCHAR(10),   -- Dishwasher usage frequency
    CWASHER         VARCHAR(10),   -- Clothes washer flag
    DRYER           VARCHAR(10),   -- Dryer flag
    NUMMEAL         VARCHAR(10),   -- Meals cooked per week
    TOTALBTU        VARCHAR(20),   -- Total BTU all fuels
    TOTALDOL        VARCHAR(20)    -- Total cost all fuels
);
GO
