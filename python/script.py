# ============================================================
# FILE: load_recs.py
# PURPOSE: Load EIA RECS 2020 CSV into SQL Server
# WHY PYTHON: SSMS "Import Flat File" crashes on 600+ column
#             CSV files (FillWeight > 65535 error). Python
#             loads only the 41 required columns directly.
# REQUIREMENTS:
#   pip install pandas sqlalchemy pyodbc
# USAGE:
#   1. Update SERVER_NAME with your SQL Server instance name
#      (visible at top of SSMS Object Explorer)
#   2. Update CSV_PATH with the path to your downloaded CSV
#   3. Run: python load_recs.py
# ============================================================

import pandas as pd
from sqlalchemy import create_engine

# ── Configuration ─────────────────────────────────────────────
CSV_PATH    = r'C:\Swati\recs2020_public_v7.csv'   # Update this path
SERVER_NAME = r'localhost'                          # Update with your server name
DATABASE    = 'recs2020'
TABLE_NAME  = 'recs_main'

# ── Columns to extract from 600+ column CSV ───────────────────
# Only the 41 columns needed for analysis
COLS = [
    # Identifiers & Geography
    'DOEID', 'REGIONC', 'DIVISION', 'STATE_FIPS',
    'state_postal', 'state_name', 'BA_climate', 'IECC_climate_code',

    # Housing & Demographics
    'TYPEHUQ', 'TOTSQFT_EN', 'TOTHSQFT',
    'NHSLDMEM', 'MONEYPY', 'HHAGE', 'EMPLOYHH',

    # Electricity Consumption (kWh)
    'KWH',      # Total electricity → renamed to KWHIN
    'KWHCOL',   # Air conditioning
    'KWHSPH',   # Space heating
    'KWHWTH',   # Water heating
    'KWHOTH',   # Other uses

    # Energy Costs ($)
    'DOLLAREL', 'DOLLARNG', 'DOLLARFO', 'DOLLARLP',

    # Energy in BTUs (all fuel types)
    'BTUEL', 'BTUNG', 'BTUFO', 'BTULP',
    'BTUWD',    # Wood BTU → renamed to BTUWOOD

    # Equipment
    'ACEQUIPM_PUB',  # AC equipment type
    'ACEQUIPAGE',    # AC equipment age
    'FUELHEAT',      # Primary heating fuel
    'EQUIPAGE',      # Heating equipment age

    # Appliances
    'NUMCFAN', 'NUMFRIG', 'DWASHUSE',
    'CWASHER', 'DRYER', 'NUMMEAL',

    # Totals
    'TOTALBTU', 'TOTALDOL'
]

# ── Load CSV ──────────────────────────────────────────────────
print("Reading CSV...")
df = pd.read_csv(CSV_PATH, usecols=COLS, low_memory=False)
print(f"  Loaded {len(df):,} rows, {len(df.columns)} columns")

# Rename columns to match SQL table definition
df.rename(columns={
    'KWH':   'KWHIN',   # Total kWh → KWHIN
    'BTUWD': 'BTUWOOD'  # Wood BTU → BTUWOOD
}, inplace=True)

# ── Connect to SQL Server ─────────────────────────────────────
print("Connecting to SQL Server...")
connection_string = (
    f'mssql+pyodbc://{SERVER_NAME}/{DATABASE}'
    f'?driver=ODBC+Driver+17+for+SQL+Server'
    f'&trusted_connection=yes'
)
engine = create_engine(connection_string)

# ── Load into SQL Server ──────────────────────────────────────
print(f"Loading into SQL Server table '{TABLE_NAME}'...")
df.to_sql(TABLE_NAME, engine, if_exists='replace', index=False)


