from __future__ import annotations

import math
from typing import Any

import numpy as np

from app.data.pbs_data import YEARS, CROPS, get_province, get_rainfall_for_year, get_yield_series


PRICE_2023_PKR_PER_TON = {
    'wheat': 87_500,
    'rice': 150_000,
    'cotton': 260_000,
    'sugarcane': 7_500,
    'maize': 55_000,
}

COST_2023_PKR_PER_ACRE = {
    'wheat': 30_000,
    'rice': 48_000,
    'cotton': 58_000,
    'sugarcane': 78_000,
    'maize': 36_000,
}

WATER_REQUIREMENT_MM = {
    'wheat': 450,
    'rice': 1200,
    'cotton': 700,
    'sugarcane': 1600,
    'maize': 550,
}

MARKET_GROWTH = {
    'wheat': 0.045,
    'rice': 0.052,
    'cotton': 0.035,
    'sugarcane': 0.032,
    'maize': 0.058,
}

DEMAND_GROWTH = {
    'wheat': 0.016,
    'rice': 0.021,
    'cotton': 0.006,
    'sugarcane': 0.011,
    'maize': 0.028,
}

INPUT_COST_INFLATION = {
    'wheat': 0.055,
    'rice': 0.064,
    'cotton': 0.068,
    'sugarcane': 0.070,
    'maize': 0.058,
}

SOIL_YIELD_FACTOR = {
    'loam': 1.00,
    'clay': 0.96,
    'sandy': 0.90,
    'saline': 0.82,
    'mixed': 0.94,
}

SOIL_COST_FACTOR = {
    'loam': 1.00,
    'clay': 1.04,
    'sandy': 1.10,
    'saline': 1.17,
    'mixed': 1.07,
}

WATER_FACTOR = {
    'low': 0.88,
    'medium': 1.00,
    'high': 1.05,
}

WATER_COST_FACTOR = {
    'low': 1.18,
    'medium': 1.00,
    'high': 0.96,
}

DISEASE_BASE_RISK = {
    'wheat': 0.25,
    'rice': 0.27,
    'cotton': 0.46,
    'sugarcane': 0.34,
    'maize': 0.24,
}

FERTILIZER_NEEDS = {
    'wheat': ['Nitrogen split doses', 'DAP at sowing', 'Potash if soil test is low'],
    'rice': ['DAP before transplanting', 'Nitrogen in 2-3 splits', 'Zinc in deficient soils'],
    'cotton': ['Balanced NPK', 'Potash for boll development', 'Boron if flower drop appears'],
    'sugarcane': ['High nitrogen demand', 'Phosphorus at planting', 'Potash for cane weight'],
    'maize': ['DAP at sowing', 'Nitrogen at knee-high stage', 'Zinc if leaves show striping'],
}


def _clean(value: float, digits: int = 2) -> float:
    if not math.isfinite(value):
        return 0.0
    return round(float(value), digits)


def _crop_id(value: str) -> str:
    crop = value.strip().lower().replace(' ', '-')
    return crop if crop in CROPS else 'wheat'


def _risk_level(score: float) -> str:
    if score >= 0.66:
        return 'high'
    if score >= 0.38:
        return 'medium'
    return 'low'


def _demand_label(index: float) -> str:
    if index >= 1.22:
        return 'strong growth'
    if index >= 1.08:
        return 'growing'
    if index >= 0.95:
        return 'stable'
    return 'weak'


def _weather_risks(rainfall: float, temp_max: float, water: str) -> tuple[list[str], float]:
    risks: list[str] = []
    score = 0.12
    if rainfall < 160:
        risks.append('Drought stress')
        score += 0.28
    if rainfall > 310:
        risks.append('Flood/waterlogging risk')
        score += 0.22
    if temp_max > 41:
        risks.append('Heat stress')
        score += 0.20
    if water == 'low':
        risks.append('Limited irrigation buffer')
        score += 0.18
    if not risks:
        risks.append('Normal seasonal variability')
    return risks, min(score, 0.95)


def _disease_risks(crop: str, rainfall: float, temp_max: float) -> tuple[list[str], float]:
    score = DISEASE_BASE_RISK[crop]
    risks: list[str] = []
    if crop == 'cotton':
        risks.append('Cotton leaf curl and sucking pest pressure')
    elif crop == 'rice':
        risks.append('Bacterial blight or blast in humid periods')
    elif crop == 'wheat':
        risks.append('Rust risk during cool humid spells')
    elif crop == 'sugarcane':
        risks.append('Borer and red rot scouting needed')
    else:
        risks.append('Stem borer and fall armyworm scouting needed')

    if rainfall > 280:
        risks.append('Humidity can increase fungal/bacterial disease pressure')
        score += 0.12
    if temp_max > 40:
        risks.append('Heat can increase pest pressure and crop stress')
        score += 0.10
    return risks, min(score, 0.95)


def _rainfall_projection() -> tuple[float, float]:
    x = np.array(YEARS, dtype=float)
    y = np.array([get_rainfall_for_year(year) for year in YEARS], dtype=float)
    slope, intercept = np.polyfit(x, y, 1)
    return float(slope), float(intercept)


def _yield_trend(district: str, crop: str) -> tuple[float, float, float, float]:
    series = get_yield_series(district, crop)
    x = series['year'].to_numpy(dtype=float)
    y = series['yield_t_acre'].to_numpy(dtype=float)
    slope, intercept = np.polyfit(x, y, 1)
    predicted = slope * x + intercept
    ss_res = float(np.sum((y - predicted) ** 2))
    ss_tot = float(np.sum((y - np.mean(y)) ** 2))
    r_squared = 1.0 - ss_res / ss_tot if ss_tot else 0.0
    residual_std = float(np.std(y - predicted)) if len(y) > 1 else 0.0
    return float(slope), float(intercept), max(0.0, min(1.0, r_squared)), residual_std


def _future_rainfall(year: int, step: int, slope: float, intercept: float) -> float:
    projected = slope * year + intercept
    cycle = math.sin(step * 1.35) * 32.0
    return max(80.0, min(380.0, projected + cycle))


def _budget_pressure(total_cost: float, budget: float) -> float:
    if budget <= 0:
        return 0.22
    if total_cost <= budget:
        return 0.0
    over = (total_cost - budget) / max(1.0, budget)
    return min(0.28, over * 0.55)


def _confidence(years_ahead: int, r_squared: float, risk_score: float, is_long_range: bool) -> float:
    base = 0.82 if not is_long_range else 0.72
    score = base + min(0.10, r_squared * 0.08) - risk_score * 0.18 - years_ahead * 0.012
    return max(0.35, min(0.88, score))


def _crop_prediction(
    *,
    district: str,
    crop: str,
    farm_acres: float,
    soil_type: str,
    water_availability: str,
    budget_pkr: float,
    prediction_years: int,
) -> dict[str, Any]:
    slope, intercept, r_squared, residual_std = _yield_trend(district, crop)
    rain_slope, rain_intercept = _rainfall_projection()
    province = get_province(district)
    soil_yield = SOIL_YIELD_FACTOR.get(soil_type, SOIL_YIELD_FACTOR['loam'])
    soil_cost = SOIL_COST_FACTOR.get(soil_type, SOIL_COST_FACTOR['loam'])
    water_yield = WATER_FACTOR.get(water_availability, WATER_FACTOR['medium'])
    water_cost = WATER_COST_FACTOR.get(water_availability, WATER_COST_FACTOR['medium'])

    yearly = []
    for step in range(1, prediction_years + 1):
        year = 2023 + step
        rainfall = _future_rainfall(year, step, rain_slope, rain_intercept)
        temp_max = 36.5 + step * 0.18 + (step % 3) * 1.4
        weather_labels, weather_score = _weather_risks(rainfall, temp_max, water_availability)
        disease_labels, disease_score = _disease_risks(crop, rainfall, temp_max)

        trend_yield = max(0.25, slope * year + intercept)
        weather_yield_factor = 1.0 - max(0.0, weather_score - 0.22) * 0.24
        uncertainty_drag = residual_std * 0.03 * step
        yield_t_acre = max(
            0.20,
            trend_yield * soil_yield * water_yield * weather_yield_factor - uncertainty_drag,
        )

        price_per_ton = PRICE_2023_PKR_PER_TON[crop] * ((1 + MARKET_GROWTH[crop]) ** step)
        demand_index = 1.0 + DEMAND_GROWTH[crop] * step
        cost_per_acre = (
            COST_2023_PKR_PER_ACRE[crop]
            * ((1 + INPUT_COST_INFLATION[crop]) ** step)
            * soil_cost
            * water_cost
        )
        total_cost = cost_per_acre * farm_acres
        production = yield_t_acre * farm_acres
        revenue = production * price_per_ton * min(1.18, demand_index)
        profit = revenue - total_cost
        budget_score = _budget_pressure(total_cost, budget_pkr)
        market_score = 0.30 if demand_index >= 1.08 else 0.42
        if profit < 0:
            market_score += 0.25

        risk_score = min(
            0.96,
            weather_score * 0.34 + disease_score * 0.25 + market_score * 0.17 + budget_score,
        )
        confidence = _confidence(step, r_squared, risk_score, prediction_years == 10)

        yearly.append({
            'year': year,
            'estimatedYieldTAcre': _clean(yield_t_acre, 3),
            'estimatedProductionTons': _clean(production, 2),
            'expectedCostPerAcrePkr': int(round(cost_per_acre)),
            'expectedTotalCostPkr': int(round(total_cost)),
            'expectedRevenuePkr': int(round(revenue)),
            'expectedProfitPkr': int(round(profit)),
            'marketDemandIndex': _clean(demand_index, 3),
            'marketDemandTrend': _demand_label(demand_index),
            'weatherRiskScore': _clean(weather_score, 3),
            'weatherRisks': weather_labels,
            'diseasePestRiskScore': _clean(disease_score, 3),
            'diseasePestRisks': disease_labels,
            'fertilizerNeeds': FERTILIZER_NEEDS[crop],
            'waterRequirementMm': WATER_REQUIREMENT_MM[crop],
            'waterAvailability': water_availability,
            'riskScore': _clean(risk_score, 3),
            'riskLevel': _risk_level(risk_score),
            'confidenceScore': int(round(confidence * 100)),
        })

    avg_profit = float(np.mean([row['expectedProfitPkr'] for row in yearly])) if yearly else 0.0
    avg_production = float(np.mean([row['estimatedProductionTons'] for row in yearly])) if yearly else 0.0
    avg_risk = float(np.mean([row['riskScore'] for row in yearly])) if yearly else 0.0
    avg_confidence = float(np.mean([row['confidenceScore'] for row in yearly])) if yearly else 0.0
    final_row = yearly[-1] if yearly else {}
    crop_label = crop.replace('-', ' ').title()

    if avg_profit <= 0:
        recommendation = (
            f'{crop_label} looks financially weak under this scenario. Reduce input cost, '
            'improve irrigation certainty, or compare another crop before committing.'
        )
    elif avg_risk >= 0.66:
        recommendation = (
            f'{crop_label} can be profitable but risk is high. Use staged investment, disease scouting, '
            'and water planning before expanding acreage.'
        )
    else:
        recommendation = (
            f'{crop_label} is a reasonable option for {district.replace("-", " ").title()} under the selected '
            'area, water, soil, and budget assumptions.'
        )

    return {
        'crop': crop,
        'cropLabel': crop_label,
        'province': province,
        'yearly': yearly,
        'summary': {
            'averageProductionTons': _clean(avg_production, 2),
            'averageProfitPkr': int(round(avg_profit)),
            'averageRiskScore': _clean(avg_risk, 3),
            'averageConfidenceScore': int(round(avg_confidence)),
            'finalYearYieldTAcre': final_row.get('estimatedYieldTAcre'),
            'finalYearProfitPkr': final_row.get('expectedProfitPkr'),
            'marketDemandTrend': final_row.get('marketDemandTrend'),
            'riskLevel': _risk_level(avg_risk),
            'confidenceScore': int(round(avg_confidence)),
        },
        'modelDiagnostics': {
            'historicalYieldR2': _clean(r_squared, 3),
            'yieldTrendSlopeTAcrePerYear': _clean(slope, 4),
            'historicalResidualStd': _clean(residual_std, 3),
        },
        'finalAIRecommendation': recommendation,
    }


def predict_future_crops(request: Any) -> dict[str, Any]:
    district = str(request.district).lower()
    crops = []
    for crop in request.crops:
        crop_id = _crop_id(crop)
        if crop_id not in crops:
            crops.append(crop_id)
    if not crops:
        crops = ['wheat']

    prediction_years = 10 if int(request.predictionYears) == 10 else 5
    soil_type = str(request.soilType).lower()
    water_availability = str(request.waterAvailability).lower()
    if water_availability not in WATER_FACTOR:
        water_availability = 'medium'

    crop_outputs = [
        _crop_prediction(
            district=district,
            crop=crop,
            farm_acres=float(request.farmAcres),
            soil_type=soil_type,
            water_availability=water_availability,
            budget_pkr=float(request.budgetPkr),
            prediction_years=prediction_years,
        )
        for crop in crops
    ]

    comparison = [
        {
            'crop': item['crop'],
            'cropLabel': item['cropLabel'],
            'averageProductionTons': item['summary']['averageProductionTons'],
            'averageProfitPkr': item['summary']['averageProfitPkr'],
            'averageRiskScore': item['summary']['averageRiskScore'],
            'riskLevel': item['summary']['riskLevel'],
            'confidenceScore': item['summary']['confidenceScore'],
            'marketDemandTrend': item['summary']['marketDemandTrend'],
        }
        for item in crop_outputs
    ]
    ranked = sorted(
        comparison,
        key=lambda row: (
            float(row['averageProfitPkr']),
            -float(row['averageRiskScore']),
            float(row['confidenceScore']),
        ),
        reverse=True,
    )
    for index, row in enumerate(ranked, start=1):
        row['recommendationRank'] = index

    best_crop = ranked[0]['crop'] if ranked else crops[0]
    highest_risk = max(comparison, key=lambda row: row['averageRiskScore'])['crop'] if comparison else crops[0]
    best_output = next((item for item in crop_outputs if item['crop'] == best_crop), crop_outputs[0])

    return {
        'isSampleModel': True,
        'replaceableModel': True,
        'dataSource': (
            'Future prediction uses CropSense historical yield/rainfall data from 2005-2023 plus transparent '
            'scenario assumptions for market demand, input costs, water availability, disease pressure, and soil.'
        ),
        'warning': (
            'Forecasts beyond the historical range are uncertain. Replace this scenario model with trained ML '
            'or official market/weather forecasts when those data sources are available.'
        ),
        'filters': {
            'district': district,
            'province': get_province(district),
            'crops': crops,
            'farmAcres': float(request.farmAcres),
            'soilType': soil_type,
            'waterAvailability': water_availability,
            'budgetPkr': float(request.budgetPkr),
            'predictionYears': prediction_years,
            'baseHistoricalYears': '2005-2023',
            'futureYears': [2024, 2023 + prediction_years],
        },
        'bestCrop': best_crop,
        'highestRiskCrop': highest_risk,
        'finalAIRecommendation': (
            f'{best_output["cropLabel"]} is the strongest option in this scenario because it has the best '
            f'profit/risk balance. {best_output["finalAIRecommendation"]}'
        ),
        'comparison': ranked,
        'crops': crop_outputs,
    }
