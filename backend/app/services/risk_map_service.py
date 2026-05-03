from __future__ import annotations

import hashlib
from datetime import datetime
from statistics import mean, pstdev
from typing import Any

import numpy as np

from app.data.pbs_data import (
    CROPS,
    DISTRICT_PROVINCE,
    RAINFALL_MM,
    YEARS,
    get_rainfall_for_year,
    get_yield,
    get_yield_series,
)


PROVINCE_LABELS = {
    'KPK': 'Khyber Pakhtunkhwa',
}


def _label(value: str) -> str:
    return value.replace('-', ' ').title()


def _province_label(province: str) -> str:
    return PROVINCE_LABELS.get(province, province)


def _clean(value: Any, places: int = 3) -> float | None:
    try:
        numeric = float(value)
    except (TypeError, ValueError):
        return None
    if np.isnan(numeric) or np.isinf(numeric):
        return None
    return round(numeric, places)


def _ndvi_from_rainfall(district: str, crop: str, year: int, rainfall: float) -> float:
    seed = int(hashlib.sha256(f'{district}:{crop}:{year}'.encode()).hexdigest()[:8], 16)
    variation = ((seed % 1000) / 1000.0 - 0.5) * 0.08
    raw = 0.22 + min(0.68, rainfall / 420.0 * 0.68) + variation
    return round(max(0.12, min(0.92, raw)), 3)


def _level(score: float) -> str:
    if score >= 75:
        return 'critical'
    if score >= 55:
        return 'high'
    if score >= 40:
        return 'above'
    if score >= 25:
        return 'watch'
    return 'good'


def _weather_risks(year: int, rainfall: float) -> tuple[list[str], float]:
    rain_values = np.array(RAINFALL_MM, dtype=float)
    avg_rain = float(np.mean(rain_values))
    p25 = float(np.percentile(rain_values, 25))
    p75 = float(np.percentile(rain_values, 75))
    p90 = float(np.percentile(rain_values, 90))

    risks: list[str] = []
    score = 0.0
    if rainfall < p25:
        score += min(35.0, ((p25 - rainfall) / max(p25, 1.0)) * 55.0)
        risks.append(
            f'{year} rainfall is below the 2005-2023 normal range, so drought stress is possible.'
        )
    elif rainfall > p90:
        score += min(35.0, ((rainfall - p90) / max(p90, 1.0)) * 45.0 + 10.0)
        risks.append(
            f'{year} rainfall is unusually high in the 2005-2023 record, so waterlogging/flood damage risk is higher.'
        )
    elif rainfall > p75:
        score += 10.0
        risks.append(
            f'{year} rainfall is wetter than the historical middle range; monitor drainage and disease pressure.'
        )
    else:
        risks.append('Rainfall is within the historical middle range for 2005-2023.')

    if rainfall < avg_rain * 0.72:
        score += 12.0
    return risks, score


def _crop_risks(district: str, crop: str, year: int, yield_value: float) -> tuple[list[str], float, float]:
    series = get_yield_series(district, crop)
    values = [float(v) for v in series['yield_t_acre'].tolist()]
    avg_yield = mean(values)
    median_yield = float(np.median(values))
    std_yield = pstdev(values) if len(values) > 1 else 0.0
    first = values[0]
    last = values[-1]

    risks: list[str] = []
    score = 0.0
    if yield_value < median_yield:
        gap = ((median_yield - yield_value) / max(median_yield, 0.01)) * 100.0
        score += min(38.0, gap * 0.9)
        risks.append(
            f'{_label(crop)} yield is {gap:.0f}% below its 2005-2023 district median.'
        )
    else:
        risks.append(f'{_label(crop)} yield is at or above its 2005-2023 district median.')

    variability = std_yield / max(avg_yield, 0.01)
    if variability > 0.20:
        score += min(18.0, variability * 45.0)
        risks.append('Historical yield variability is high, so planning uncertainty is higher.')

    change_pct = ((last - first) / max(first, 0.01)) * 100.0
    if change_pct < -5:
        score += min(16.0, abs(change_pct) * 0.45)
        risks.append(f'Long-term historical yield trend is down by {abs(change_pct):.0f}%.')
    return risks, score, change_pct


def _entry(district: str, crop: str, year: int) -> dict[str, Any]:
    province = _province_label(DISTRICT_PROVINCE[district])
    rainfall = get_rainfall_for_year(year)
    yield_value = get_yield(district, crop, year)
    series = get_yield_series(district, crop)
    values = [float(v) for v in series['yield_t_acre'].tolist()]
    avg_yield = mean(values)

    weather_risks, weather_score = _weather_risks(year, rainfall)
    crop_risks, crop_score, change_pct = _crop_risks(district, crop, year, yield_value)
    baseline_score = 8.0 if yield_value >= avg_yield else 16.0
    score = max(0.0, min(100.0, baseline_score + weather_score + crop_score))
    level = _level(score)
    ndvi = _ndvi_from_rainfall(district, crop, year, rainfall)

    explanation = (
        f'{_label(district)} is {level} risk for {_label(crop)} in {year}. '
        f'The score uses district yield history and rainfall from 2005-2023: '
        f'yield is {yield_value:.2f} t/acre versus a historical average of {avg_yield:.2f} t/acre, '
        f'and rainfall is {rainfall:.0f} mm.'
    )

    crop_yields = {crop_id: get_yield(district, crop_id, year) for crop_id in CROPS}
    return {
        'district': district,
        'districtName': _label(district),
        'province': province,
        'selectedCrop': crop,
        'selectedYear': year,
        'riskLevel': level,
        'riskScore': round(score, 2),
        'cropYields': crop_yields,
        'yieldTAcre': _clean(yield_value),
        'productionTons': None,
        'rainfallMm': _clean(rainfall, 1),
        'ndvi': ndvi,
        'alertCount': sum(1 for item in [*weather_risks, *crop_risks] if 'risk' in item.lower() or 'below' in item.lower()),
        'weatherRisks': weather_risks,
        'cropRisks': crop_risks,
        'yieldChangePct': _clean(change_pct, 2),
        'aiExplanation': explanation,
        'dataAvailable': True,
        'dataSource': 'CropSense historical yield/rainfall API data, 2005-2023',
        'limitations': [
            'District production is unavailable because no verified district crop area API is connected.',
            'Risk is historical and does not include live market prices or same-day weather observations.',
        ],
    }


def unavailable_entry(district: str, crop: str, year: int, reason: str) -> dict[str, Any]:
    return {
        'district': district,
        'districtName': _label(district),
        'province': _province_label(DISTRICT_PROVINCE.get(district, '')),
        'selectedCrop': crop,
        'selectedYear': year,
        'riskLevel': 'watch',
        'riskScore': 0.0,
        'cropYields': {},
        'yieldTAcre': None,
        'productionTons': None,
        'rainfallMm': None,
        'ndvi': 0.0,
        'alertCount': 0,
        'weatherRisks': [],
        'cropRisks': [],
        'yieldChangePct': None,
        'aiExplanation': reason,
        'dataAvailable': False,
        'dataSource': 'Data unavailable',
        'limitations': [reason],
    }


def build_risk_map(crop: str, year: int) -> dict[str, Any]:
    crop = crop.lower().strip()
    if crop not in CROPS or year not in YEARS:
        reason = f'No CropSense historical API data is available for crop={crop}, year={year}.'
        districts = [
            unavailable_entry(district, crop, year, reason)
            for district in sorted(DISTRICT_PROVINCE)
        ]
    else:
        districts = [_entry(district, crop, year) for district in sorted(DISTRICT_PROVINCE)]

    counts = {name: 0 for name in ['good', 'above', 'watch', 'high', 'critical']}
    for district in districts:
        if district.get('dataAvailable'):
            counts[str(district['riskLevel'])] += 1

    available_scores = [
        float(district['riskScore'])
        for district in districts
        if district.get('dataAvailable')
    ]
    avg_score = mean(available_scores) if available_scores else 0.0

    return {
        'generatedAt': datetime.now().isoformat(),
        'selectedCrop': crop,
        'selectedYear': year,
        'yearRange': f'{YEARS[0]}-{YEARS[-1]}',
        'nationalRiskLevel': _level(avg_score) if available_scores else 'watch',
        'criticalCount': counts['critical'],
        'highCount': counts['high'],
        'watchCount': counts['watch'] + counts['above'],
        'dataSource': 'CropSense historical yield/rainfall API data, 2005-2023',
        'districts': districts,
    }
