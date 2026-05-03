#!/usr/bin/env python3
"""
backend/scripts/seed_real_data.py

Validates the in-memory PBS dataset and prints a summary report.
No database writes — data lives in app/data/pbs_data.py and is
served directly from a pandas DataFrame at runtime.

Run from the repo root:
    python backend/scripts/seed_real_data.py
"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from app.data.pbs_data import (
    _PROVINCE_DF, YEARS, CROPS, PROVINCES, ANCHORS,
    get_yield, get_yield_series, EVENT_MULTIPLIERS,
)
import numpy as np


SEP = '-' * 68


def main():
    print(SEP)
    print('  CropSense PBS Data Validation Report')
    print(SEP)
    print(f'  DataFrame rows : {len(_PROVINCE_DF)}  '
          f'({len(PROVINCES)} provinces x {len(CROPS)} crops x {len(YEARS)} years)')
    print(f'  Year range     : {YEARS[0]}-{YEARS[-1]}')
    print(f'  Crops          : {", ".join(CROPS)}')
    print(f'  Provinces      : {", ".join(PROVINCES)}')
    print()

    # ── 1. Anchor value verification ──────────────────────────────────────
    print('1. Anchor Value Verification (trend line only, before events)')
    print(SEP)
    hdr = f'  {"Province + Crop":<26} {"2005 anchor":>11} {"2005 trend":>10} {"2023 anchor":>11} {"2023 trend":>10}  OK?'
    print(hdr)
    print('  ' + '-' * 64)

    all_ok = True
    for (province, crop), (anchor_05, anchor_23) in sorted(ANCHORS.items()):
        df = _PROVINCE_DF[
            (_PROVINCE_DF['province'] == province) &
            (_PROVINCE_DF['crop']     == crop)
        ].sort_values('year')

        trend_05 = float(df[df['year'] == 2005].iloc[0]['yield_trend'])
        trend_23 = float(df[df['year'] == 2023].iloc[0]['yield_trend'])
        ok = abs(trend_05 - anchor_05) < 0.01 and abs(trend_23 - anchor_23) < 0.01
        if not ok:
            all_ok = False
        mark = 'OK' if ok else 'FAIL'
        label = f'{province} {crop}'
        print(f'  {label:<26} {anchor_05:>11.3f} {trend_05:>10.3f} '
              f'{anchor_23:>11.3f} {trend_23:>10.3f}  {mark}')

    print()
    print('  ' + ('All anchor values match PBS figures.' if all_ok
                  else 'WARNING: some anchor values differ - check ANCHORS dict.'))

    # ── 2. Sample district series ──────────────────────────────────────────
    print()
    print('2. Sample Series - Faisalabad Wheat (2005-2023)')
    print(SEP)
    series = get_yield_series('faisalabad', 'wheat')
    for _, row in series.iterrows():
        year  = int(row['year'])
        y     = float(row['yield_t_acre'])
        mult  = float(row['event_mult'])
        trend = float(row['yield_trend'])
        note  = ''
        if mult < 1.0:
            note = f'  [drought/flood x{mult:.2f}]'
        elif mult > 1.0:
            note = f'  [good season   x{mult:.2f}]'
        print(f'  {year}: {y:6.3f} t/acre  (trend {trend:.3f}){note}')

    # ── 3. Provincial means ────────────────────────────────────────────────
    print()
    print('3. Provincial Mean Yield 2005-2023 (t/acre)')
    print(SEP)
    summary = _PROVINCE_DF.groupby(['province', 'crop'])['yield_t_acre'].agg(
        mean='mean', std='std', min_='min', max_='max'
    ).reset_index()
    cur_prov = ''
    for _, row in summary.iterrows():
        if row['province'] != cur_prov:
            cur_prov = row['province']
            print(f'\n  {cur_prov}')
        print(f'    {row["crop"]:<10}  mean={row["mean"]:.3f}  '
              f'std={row["std"]:.3f}  min={row["min_"]:.3f}  max={row["max_"]:.3f}')

    # ── 4. Event year summary ──────────────────────────────────────────────
    print()
    print()
    print('4. Event Year Multipliers')
    print(SEP)
    for year, mult in sorted(EVENT_MULTIPLIERS.items()):
        kind = 'drought/flood' if mult < 1.0 else 'good season'
        print(f'  {year}: x{mult:.2f}  ({kind})')

    # ── 5. District sample ─────────────────────────────────────────────────
    print()
    print('5. District Sample - 2023 Wheat Yields (selected)')
    print(SEP)
    sample_districts = [
        'faisalabad', 'multan', 'sargodha',   # Punjab
        'larkana', 'hyderabad',                # Sindh
        'mardan', 'peshawar',                  # KPK
        'quetta', 'naseerabad',                # Balochistan
    ]
    for d in sample_districts:
        y = get_yield(d, 'wheat', 2023)
        print(f'  {d:<18}: {y:.3f} t/acre')

    print()
    print(SEP)
    print('  Data ready. Routes serve this DataFrame - no database required.')
    print(SEP)


if __name__ == '__main__':
    main()
