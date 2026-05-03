"""
Structured analytics endpoint for the CropSense Analytics screen.

The endpoint keeps the old route path intact while returning a cleaner
section-based JSON contract for charts, probability estimates, tests,
confidence intervals, and farmer-friendly AI-style summaries.
"""
from __future__ import annotations

import math
from fastapi import APIRouter, Query

import numpy as np

from app.data.pbs_data import YEARS, get_yield_series, get_rainfall_for_year
from app.services.analytics_stats import (
    chi_square_weather_risk,
    clean_number,
    confidence_interval,
    correlation_analysis,
    descriptive_stats,
    empirical_probability,
    independent_t_test,
    multi_factor_regression,
    one_way_anova,
    risk_level_from_probability,
    simple_linear_regression,
    year_over_year_growth,
)

router = APIRouter()

CROPS = ['wheat', 'rice', 'cotton', 'sugarcane', 'maize']

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

CROP_SEASON = {
    'wheat': 'Rabi',
    'rice': 'Kharif',
    'cotton': 'Kharif',
    'sugarcane': 'Annual',
    'maize': 'Kharif',
}

SOIL_YIELD_FACTOR = {
    'loam': 1.00,
    'clay': 0.97,
    'sandy': 0.91,
    'saline': 0.84,
    'mixed': 0.95,
}

SOIL_COST_FACTOR = {
    'loam': 1.00,
    'clay': 1.04,
    'sandy': 1.10,
    'saline': 1.16,
    'mixed': 1.06,
}

DROUGHT_YEARS = {2009, 2015, 2018}
FLOOD_YEARS = {2010, 2022}


def _label(value: str) -> str:
    return value.replace('-', ' ').title()


def _selected_years(start_year: int, end_year: int) -> list[int]:
    start = max(min(start_year, end_year), min(YEARS))
    end = min(max(start_year, end_year), max(YEARS))
    return [year for year in YEARS if start <= year <= end]


def _season_crops(season: str, crop: str) -> list[str]:
    season_l = season.lower()
    if crop.lower() in CROPS:
        candidates = [crop.lower()]
    else:
        candidates = CROPS[:]

    if season_l in {'all', 'any'}:
        return candidates

    return [
        c for c in candidates
        if CROP_SEASON[c].lower() == season_l or CROP_SEASON[c].lower() == 'annual'
    ] or candidates


def _weather_row(year: int) -> dict:
    idx = YEARS.index(year)
    rainfall = float(get_rainfall_for_year(year))
    temp_max = 36.0 + (idx % 3) * 2.0
    if year in DROUGHT_YEARS:
        temp_max += 2.0
    temp_min = 18.0 + (idx % 4) * 1.5
    weather_stress = rainfall < 160 or rainfall > 285 or temp_max > 40
    return {
        'rainfallMm': clean_number(rainfall, 1),
        'tempMaxC': clean_number(temp_max, 1),
        'tempMinC': clean_number(temp_min, 1),
        'weatherStress': weather_stress,
        'weatherRiskType': (
            'flood' if rainfall > 285 else
            'drought' if rainfall < 160 else
            'heat' if temp_max > 40 else
            'normal'
        ),
    }


def _market_price(crop: str, year: int) -> float:
    idx = YEARS.index(year)
    base = PRICE_2023_PKR_PER_TON[crop]
    trend = 0.68 + (idx / max(1, len(YEARS) - 1)) * 0.32
    shock = 1.0
    if year in {2010, 2022}:
        shock -= 0.06
    if year in {2017, 2019, 2021}:
        shock += 0.04
    if crop == 'cotton' and year >= 2016:
        shock += 0.05
    return max(1.0, base * trend * shock)


def _cost_components(crop: str, year: int, rainfall: float, temp_max: float, soil_type: str) -> dict:
    idx = YEARS.index(year)
    base = COST_2023_PKR_PER_ACRE[crop]
    inflation = 0.64 + (idx / max(1, len(YEARS) - 1)) * 0.36
    weather_extra = 1.0
    if rainfall < 160:
        weather_extra += 0.08
    if temp_max > 40:
        weather_extra += 0.04

    soil_l = soil_type.lower()
    cost_factor = SOIL_COST_FACTOR.get(soil_l, SOIL_COST_FACTOR['mixed'])
    total_cost = base * inflation * weather_extra * cost_factor
    fertilizer_cost = total_cost * 0.34
    irrigation_cost = total_cost * (0.18 if rainfall < 180 else 0.12)
    return {
        'costPerAcre': total_cost,
        'fertilizerCostPerAcre': fertilizer_cost,
        'irrigationCostPerAcre': irrigation_cost,
    }


def _yield_adjusted(raw_yield: float, soil_type: str) -> float:
    factor = SOIL_YIELD_FACTOR.get(soil_type.lower(), SOIL_YIELD_FACTOR['mixed'])
    return max(0.05, raw_yield * factor)


def _yearly_rows(district: str, crop: str, years: list[int], farm_acres: float, soil_type: str) -> list[dict]:
    series = get_yield_series(district, crop)
    by_year = {
        int(row['year']): float(row['yield_t_acre'])
        for _, row in series.iterrows()
    }

    rows: list[dict] = []
    previous_yield: float | None = None
    previous_price: float | None = None

    for year in years:
        weather = _weather_row(year)
        raw_y = by_year.get(year)
        if raw_y is None:
            continue

        yield_t_acre = _yield_adjusted(raw_y, soil_type)
        price = _market_price(crop, year)
        costs = _cost_components(
            crop,
            year,
            float(weather['rainfallMm']),
            float(weather['tempMaxC']),
            soil_type,
        )
        revenue = yield_t_acre * price
        profit = revenue - costs['costPerAcre']

        yoy = None
        if previous_yield and previous_yield > 0:
            yoy = (yield_t_acre - previous_yield) / previous_yield * 100.0

        price_drop = False
        if previous_price and previous_price > 0:
            price_drop = price < previous_price * 0.95

        rows.append({
            'year': year,
            'crop': crop,
            'season': CROP_SEASON[crop],
            'yieldTAcre': clean_number(yield_t_acre, 3),
            'rainfallMm': weather['rainfallMm'],
            'tempMaxC': weather['tempMaxC'],
            'tempMinC': weather['tempMinC'],
            'marketPricePerTon': int(round(price)),
            'costPerAcre': int(round(costs['costPerAcre'])),
            'fertilizerCostPerAcre': int(round(costs['fertilizerCostPerAcre'])),
            'irrigationCostPerAcre': int(round(costs['irrigationCostPerAcre'])),
            'revenuePerAcre': int(round(revenue)),
            'profitPerAcre': int(round(profit)),
            'totalFarmProfit': int(round(profit * farm_acres)),
            'yoyGrowthPct': clean_number(yoy, 2),
            'weatherStress': weather['weatherStress'],
            'weatherRiskType': weather['weatherRiskType'],
            'priceDrop': price_drop,
            'isDemoData': True,
        })

        previous_yield = yield_t_acre
        previous_price = price

    return rows


def _crop_metrics(crop: str, rows: list[dict], farm_acres: float) -> dict:
    yields = [r['yieldTAcre'] for r in rows]
    profits = [r['profitPerAcre'] for r in rows]
    prices = [r['marketPricePerTon'] for r in rows]

    stats = descriptive_stats(yields)
    profit_stats = descriptive_stats(profits)
    mean_yield = float(stats.get('mean') or 0.0)
    low_threshold = max(0.4, mean_yield * 0.70)
    failure_threshold = max(0.25, mean_yield * 0.55)
    high_profit_threshold = float(np.percentile(profits, 75)) if profits else 0.0

    low_yield_flags = [float(v) < low_threshold for v in yields]
    crop_failure_flags = [
        float(y) < failure_threshold or float(p) < 0
        for y, p in zip(yields, profits)
    ]
    weather_damage_flags = [
        bool(row['weatherStress']) and float(row['yieldTAcre']) < mean_yield
        for row in rows
    ]
    high_profit_flags = [float(p) >= high_profit_threshold for p in profits]
    loss_flags = [float(p) < 0 for p in profits]
    price_drop_flags = [bool(row['priceDrop']) for row in rows]

    low_yield_p = empirical_probability(low_yield_flags)
    failure_p = empirical_probability(crop_failure_flags)
    weather_damage_p = empirical_probability(weather_damage_flags)
    price_drop_p = empirical_probability(price_drop_flags)
    loss_p = empirical_probability(loss_flags)
    risk_score = (
        low_yield_p * 0.30 +
        failure_p * 0.25 +
        weather_damage_p * 0.20 +
        price_drop_p * 0.10 +
        loss_p * 0.15
    )

    regression = simple_linear_regression(
        [int(r['year']) for r in rows],
        yields,
        f'{crop} yield',
    )
    multi_reg = multi_factor_regression(
        {
            'rainfallMm': [r['rainfallMm'] for r in rows],
            'tempMaxC': [r['tempMaxC'] for r in rows],
            'fertilizerCostPerAcre': [r['fertilizerCostPerAcre'] for r in rows],
            'marketPricePerTon': prices,
        },
        yields,
        {
            'rainfallMm': rows[-1]['rainfallMm'] if rows else 0,
            'tempMaxC': rows[-1]['tempMaxC'] if rows else 0,
            'fertilizerCostPerAcre': rows[-1]['fertilizerCostPerAcre'] if rows else 0,
            'marketPricePerTon': rows[-1]['marketPricePerTon'] if rows else 0,
        },
        f'{crop} yield',
    )

    return {
        'crop': crop,
        'cropLabel': _label(crop),
        'season': CROP_SEASON[crop],
        'descriptiveStats': stats,
        'profitStats': profit_stats,
        'yieldConfidenceInterval': confidence_interval(yields),
        'profitConfidenceInterval': confidence_interval(profits),
        'yearOverYearGrowth': year_over_year_growth([int(r['year']) for r in rows], yields),
        'latestYieldTAcre': rows[-1]['yieldTAcre'] if rows else 0,
        'latestProfitPerAcre': rows[-1]['profitPerAcre'] if rows else 0,
        'expectedProfitPerAcre': int(round(float(profit_stats.get('mean') or 0))),
        'totalExpectedProfit': int(round(float(profit_stats.get('mean') or 0) * farm_acres)),
        'marketPricePerTon': PRICE_2023_PKR_PER_TON[crop],
        'farmingCostPerAcre': COST_2023_PKR_PER_ACRE[crop],
        'roiPct': clean_number(
            ((float(profit_stats.get('mean') or 0) / COST_2023_PKR_PER_ACRE[crop]) * 100.0),
            1,
        ),
        'breakEvenYieldTAcre': clean_number(
            COST_2023_PKR_PER_ACRE[crop] / PRICE_2023_PKR_PER_TON[crop],
            3,
        ),
        'probabilities': {
            'lowYield': clean_number(low_yield_p, 4),
            'highProfit': clean_number(empirical_probability(high_profit_flags), 4),
            'cropFailureRisk': clean_number(failure_p, 4),
            'weatherDamage': clean_number(weather_damage_p, 4),
            'priceDrop': clean_number(price_drop_p, 4),
            'loss': clean_number(loss_p, 4),
        },
        'riskLevel': risk_level_from_probability(risk_score),
        'riskScore': clean_number(risk_score * 100.0, 1),
        'thresholds': {
            'lowYieldTAcre': clean_number(low_threshold, 3),
            'failureYieldTAcre': clean_number(failure_threshold, 3),
            'highProfitPerAcre': int(round(high_profit_threshold)),
        },
        'correlations': {
            'rainfallYield': correlation_analysis(
                [r['rainfallMm'] for r in rows], yields, 'Rainfall', 'Yield'
            ),
            'temperatureYield': correlation_analysis(
                [r['tempMaxC'] for r in rows], yields, 'Temperature', 'Yield'
            ),
            'fertilizerProfit': correlation_analysis(
                [r['fertilizerCostPerAcre'] for r in rows], profits, 'Fertilizer cost', 'Profit'
            ),
            'marketPriceProfit': correlation_analysis(
                prices, profits, 'Market price', 'Profit'
            ),
        },
        'regression': regression,
        'multiFactorRegression': multi_reg,
        'yearly': rows,
    }


def _ai_insights(district: str, selected_crop: str, summary: dict, selected: dict) -> dict:
    probs = selected['probabilities']
    risk_level = selected['riskLevel']
    trend = selected['regression']

    bullets = [
        (
            f"{selected['cropLabel']} average yield is "
            f"{selected['descriptiveStats'].get('mean', 0)} t/acre across the selected years."
        ),
        (
            f"Loss probability is {round((probs.get('loss') or 0) * 100)}%, "
            f"so the current financial risk is {risk_level}."
        ),
        (
            f"Main weather risk is {summary['mainWeatherRisk']}. "
            "Use irrigation planning and drainage checks around stress years."
        ),
    ]
    if trend.get('available'):
        bullets.append(
            f"The trend model predicts about {trend.get('predictedValue')} t/acre "
            f"for {trend.get('predictedYear')} with {trend.get('modelReliabilityPct')}% reliability."
        )

    recommendation = (
        f"In {district.title()}, focus on {summary['mostProfitableCrop'].title()} for profit, "
        f"but monitor {summary['highestRiskCrop'].title()} because it has the highest risk signal. "
        f"For {selected_crop.title()}, keep costs below break-even and watch rainfall during stress periods."
    )

    return {
        'farmerSummary': (
            f"{selected_crop.title()} in {district.title()} has {risk_level} risk in the selected scenario."
        ),
        'bullets': bullets,
        'recommendation': recommendation,
    }


@router.get('/analytics/summary/{district}')
async def analytics_summary(
    district: str,
    farm_acres: float = Query(5.0, ge=0.5, le=500.0),
    crop: str = Query('all'),
    season: str = Query('all'),
    start_year: int = Query(2005, ge=2005, le=2023),
    end_year: int = Query(2023, ge=2005, le=2023),
    soil_type: str = Query('loam'),
):
    years = _selected_years(start_year, end_year)
    crops = _season_crops(season, crop)

    crop_outputs: dict[str, dict] = {}
    for crop_id in crops:
        rows = _yearly_rows(district.lower(), crop_id, years, farm_acres, soil_type)
        if rows:
            crop_outputs[crop_id] = _crop_metrics(crop_id, rows, farm_acres)

    if not crop_outputs:
        return {
            'district': district.lower(),
            'filters': {
                'crop': crop,
                'season': season,
                'startYear': years[0] if years else start_year,
                'endYear': years[-1] if years else end_year,
                'soilType': soil_type,
                'farmAcres': farm_acres,
            },
            'isDemoData': True,
            'dataSource': 'No analytics data available for the selected filters.',
            'summary': {},
            'crops': {},
        }

    selected_crop = crop.lower() if crop.lower() in crop_outputs else next(iter(crop_outputs))
    selected = crop_outputs[selected_crop]

    by_profit = sorted(crop_outputs, key=lambda c: crop_outputs[c]['expectedProfitPerAcre'], reverse=True)
    by_risk = sorted(crop_outputs, key=lambda c: crop_outputs[c]['riskScore'], reverse=True)

    def _yield_score(crop_id: str) -> float:
        mean_y = float(crop_outputs[crop_id]['descriptiveStats'].get('mean') or 0.0)
        return mean_y / 10.0 if crop_id == 'sugarcane' else mean_y

    by_yield = sorted(crop_outputs, key=_yield_score, reverse=True)
    all_rows = [row for metrics in crop_outputs.values() for row in metrics['yearly']]
    avg_yield = float(np.mean([row['yieldTAcre'] for row in all_rows])) if all_rows else 0.0
    avg_profit = float(np.mean([row['profitPerAcre'] for row in all_rows])) if all_rows else 0.0
    avg_loss_p = float(np.mean([m['probabilities']['loss'] for m in crop_outputs.values()]))

    weather_counts: dict[str, int] = {}
    for row in selected['yearly']:
        risk_type = row['weatherRiskType']
        weather_counts[risk_type] = weather_counts.get(risk_type, 0) + 1
    main_weather_risk = max(weather_counts, key=weather_counts.get) if weather_counts else 'normal'

    summary = {
        'bestPerformingCrop': by_yield[0],
        'bestYieldCrop': by_yield[0],
        'mostProfitableCrop': by_profit[0],
        'highestRiskCrop': by_risk[0],
        'averageYield': clean_number(avg_yield, 3),
        'avgGrainYieldTAcre': clean_number(avg_yield, 3),
        'expectedProfitPerAcre': int(round(avg_profit)),
        'probabilityOfLoss': clean_number(avg_loss_p, 4),
        'avgLossProbability': clean_number(avg_loss_p, 4),
        'mainWeatherRisk': main_weather_risk,
        'aiRecommendation': '',
        'recommendation': '',
    }

    summary['aiRecommendation'] = (
        f"{summary['mostProfitableCrop'].title()} is the strongest profit option. "
        f"{summary['highestRiskCrop'].title()} needs closer monitoring. "
        f"For {selected_crop.title()}, loss probability is "
        f"{round((selected['probabilities']['loss'] or 0) * 100)}%."
    )
    summary['recommendation'] = summary['aiRecommendation']

    crop_rows = [
        {
            'crop': crop_id,
            'cropLabel': metrics['cropLabel'],
            'season': metrics['season'],
            'meanYield': metrics['descriptiveStats'].get('mean'),
            'medianYield': metrics['descriptiveStats'].get('median'),
            'minYield': metrics['descriptiveStats'].get('min'),
            'maxYield': metrics['descriptiveStats'].get('max'),
            'stdDev': metrics['descriptiveStats'].get('stdDev'),
            'variance': metrics['descriptiveStats'].get('variance'),
            'range': metrics['descriptiveStats'].get('range'),
            'percentChange': metrics['descriptiveStats'].get('percentChange'),
            'expectedProfitPerAcre': metrics['expectedProfitPerAcre'],
            'probabilityLoss': metrics['probabilities']['loss'],
            'riskLevel': metrics['riskLevel'],
            'roiPct': metrics['roiPct'],
        }
        for crop_id, metrics in crop_outputs.items()
    ]

    selected_yearly = selected['yearly']
    weather_stress = [bool(row['weatherStress']) for row in selected_yearly]
    mean_y = float(selected['descriptiveStats'].get('mean') or 0.0)
    low_yield = [float(row['yieldTAcre']) < mean_y * 0.70 for row in selected_yearly]

    comparison_crop = by_yield[0] if by_yield[0] != selected_crop else (by_yield[1] if len(by_yield) > 1 else selected_crop)
    statistical_testing = {
        'tTestYield': independent_t_test(
            [row['yieldTAcre'] for row in selected_yearly],
            [row['yieldTAcre'] for row in crop_outputs[comparison_crop]['yearly']],
            selected_crop,
            comparison_crop,
            'yield',
        ),
        'tTestProfit': independent_t_test(
            [row['profitPerAcre'] for row in selected_yearly],
            [row['profitPerAcre'] for row in crop_outputs[comparison_crop]['yearly']],
            selected_crop,
            comparison_crop,
            'profit',
        ),
        'anovaYield': one_way_anova(
            {c: m['yearly'] and [row['yieldTAcre'] for row in m['yearly']] for c, m in crop_outputs.items()},
            'yield',
        ),
        'anovaProfit': one_way_anova(
            {c: m['yearly'] and [row['profitPerAcre'] for row in m['yearly']] for c, m in crop_outputs.items()},
            'profit',
        ),
        'chiSquareWeatherRisk': chi_square_weather_risk(weather_stress, low_yield),
        'seasonTest': {
            'available': False,
            'message': (
                'Season-level field records are not available in this dataset. '
                'Crop seasons are used as labels, not independent observations.'
            ),
        },
    }

    ai = _ai_insights(district, selected_crop, summary, selected)

    return {
        'district': district.lower(),
        'farmAcres': farm_acres,
        'yearRange': f'{years[0]}-{years[-1]}' if years else '',
        'isDemoData': True,
        'dataSource': (
            'Demo analytics derived from PBS-style yield anchors, historical event multipliers, '
            'and transparent cost/price assumptions. Use as decision support, not official audited data.'
        ),
        'dataQuality': {
            'yieldRecords': 'District yields are derived from in-memory PBS-style anchors.',
            'costAndPriceRecords': 'Costs and prices are scenario estimates, clearly marked as demo data.',
            'soilType': 'Soil type is a scenario adjustment because field-level soil records are not present.',
        },
        'filters': {
            'crop': crop.lower(),
            'season': season,
            'startYear': years[0] if years else start_year,
            'endYear': years[-1] if years else end_year,
            'soilType': soil_type.lower(),
            'farmAcres': farm_acres,
        },
        'summary': summary,
        'cropPerformance': {
            'rows': crop_rows,
            'explanation': 'Compares yield and profit performance for crops that match the selected filters.',
        },
        'selectedCrop': selected,
        'yieldTrend': {
            'crop': selected_crop,
            'yearly': selected_yearly,
            'descriptiveStats': selected['descriptiveStats'],
            'yearOverYearGrowth': selected['yearOverYearGrowth'],
            'regression': selected['regression'],
            'multiFactorRegression': selected['multiFactorRegression'],
            'confidenceInterval': selected['yieldConfidenceInterval'],
            'explanation': 'Trend uses yearly yield observations and a transparent linear regression model.',
        },
        'costProfit': {
            'cropRows': crop_rows,
            'yearly': selected_yearly,
            'confidenceInterval': selected['profitConfidenceInterval'],
            'explanation': 'Profit is revenue minus estimated cost per acre, scaled to farm area when needed.',
        },
        'weatherImpact': {
            'yearly': selected_yearly,
            'correlations': {
                'rainfallYield': selected['correlations']['rainfallYield'],
                'temperatureYield': selected['correlations']['temperatureYield'],
            },
            'mainWeatherRisk': main_weather_risk,
            'explanation': 'Weather impact uses empirical rainfall and temperature relationships with yield.',
        },
        'riskProbability': {
            'probabilities': selected['probabilities'],
            'riskLevel': selected['riskLevel'],
            'riskScore': selected['riskScore'],
            'thresholds': selected['thresholds'],
            'explanation': 'Probabilities are empirical frequencies from the selected historical years.',
        },
        'statisticalTesting': statistical_testing,
        'aiInsights': ai,
        'crops': crop_outputs,
    }
