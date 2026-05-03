from __future__ import annotations

import math
from typing import Any, Iterable

import numpy as np
from scipy import stats


def clean_number(value: Any, digits: int = 4) -> float | None:
    """Return a JSON-safe rounded number, or None for NaN/inf/missing values."""
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(number):
        return None
    return round(number, digits)


def _series(values: Iterable[Any]) -> np.ndarray:
    cleaned = [float(v) for v in values if clean_number(v) is not None]
    return np.array(cleaned, dtype=float)


def descriptive_stats(values: Iterable[Any]) -> dict:
    data = _series(values)
    n = int(data.size)
    if n == 0:
        return {
            'sampleSize': 0,
            'available': False,
            'message': 'No numeric observations are available.',
        }

    min_v = float(np.min(data))
    max_v = float(np.max(data))
    first = float(data[0])
    last = float(data[-1])
    pct_change = ((last - first) / abs(first) * 100.0) if first else 0.0

    return {
        'available': True,
        'sampleSize': n,
        'mean': clean_number(np.mean(data)),
        'median': clean_number(np.median(data)),
        'min': clean_number(min_v),
        'max': clean_number(max_v),
        'stdDev': clean_number(np.std(data, ddof=1) if n > 1 else 0.0),
        'variance': clean_number(np.var(data, ddof=1) if n > 1 else 0.0),
        'range': clean_number(max_v - min_v),
        'percentChange': clean_number(pct_change, 2),
    }


def year_over_year_growth(years: list[int], values: Iterable[Any]) -> list[dict]:
    data = _series(values)
    rows: list[dict] = []
    for i, value in enumerate(data):
        growth = None
        if i > 0 and data[i - 1] != 0:
            growth = clean_number((value - data[i - 1]) / abs(data[i - 1]) * 100, 2)
        rows.append({
            'year': int(years[i]),
            'value': clean_number(value),
            'yoyGrowthPct': growth,
        })
    return rows


def correlation_analysis(x_values: Iterable[Any], y_values: Iterable[Any], x_label: str, y_label: str) -> dict:
    x = _series(x_values)
    y = _series(y_values)
    n = min(int(x.size), int(y.size))
    x = x[:n]
    y = y[:n]

    if n < 3:
        return {
            'available': False,
            'xLabel': x_label,
            'yLabel': y_label,
            'message': 'At least 3 observations are required for correlation.',
        }
    if np.std(x) == 0 or np.std(y) == 0:
        return {
            'available': False,
            'xLabel': x_label,
            'yLabel': y_label,
            'message': 'Correlation cannot be calculated because one variable has no variation.',
        }

    r, p_value = stats.pearsonr(x, y)
    strength = 'weak'
    if abs(r) >= 0.70:
        strength = 'strong'
    elif abs(r) >= 0.40:
        strength = 'moderate'
    direction = 'positive' if r > 0 else 'negative'

    return {
        'available': True,
        'xLabel': x_label,
        'yLabel': y_label,
        'pearsonR': clean_number(r),
        'pValue': clean_number(p_value, 6),
        'strength': strength,
        'direction': direction,
        'explanation': (
            f'{x_label} has a {strength} {direction} relationship with {y_label}.'
        ),
    }


def confidence_interval(values: Iterable[Any], confidence: float = 0.95) -> dict:
    data = _series(values)
    n = int(data.size)
    if n < 2:
        return {
            'available': False,
            'confidencePct': int(confidence * 100),
            'message': 'At least 2 observations are required for a confidence interval.',
        }

    mean_v = float(np.mean(data))
    std_v = float(np.std(data, ddof=1))
    se = std_v / math.sqrt(n)
    if se == 0:
        low = high = mean_v
    else:
        low, high = stats.t.interval(confidence, df=n - 1, loc=mean_v, scale=se)

    return {
        'available': True,
        'confidencePct': int(confidence * 100),
        'mean': clean_number(mean_v),
        'lower': clean_number(low),
        'upper': clean_number(high),
        'sampleSize': n,
        'explanation': (
            f'Based on {n} observations, the expected value is likely between '
            f'{clean_number(low)} and {clean_number(high)} at {int(confidence * 100)}% confidence.'
        ),
    }


def simple_linear_regression(years: list[int], values: Iterable[Any], target_label: str) -> dict:
    y = _series(values)
    if len(years) != int(y.size) or int(y.size) < 3:
        return {
            'available': False,
            'message': 'At least 3 yearly observations are required for regression.',
        }

    base_year = int(min(years))
    x = np.array([yr - base_year for yr in years], dtype=float)
    reg = stats.linregress(x, y)
    fitted = reg.intercept + reg.slope * x
    residuals = y - fitted
    rmse = float(np.sqrt(np.mean(residuals ** 2)))
    r_squared = float(reg.rvalue ** 2)
    predicted_year = int(max(years) + 1)
    predicted_x = predicted_year - base_year
    predicted_value = float(reg.intercept + reg.slope * predicted_x)

    return {
        'available': True,
        'target': target_label,
        'baseYear': base_year,
        'equation': (
            f'{target_label} = {clean_number(reg.intercept)} + '
            f'{clean_number(reg.slope, 6)} * (year - {base_year})'
        ),
        'slope': clean_number(reg.slope, 6),
        'intercept': clean_number(reg.intercept),
        'rSquared': clean_number(r_squared),
        'pValue': clean_number(reg.pvalue, 6),
        'rmse': clean_number(rmse),
        'predictedYear': predicted_year,
        'predictedValue': clean_number(predicted_value),
        'modelReliabilityPct': clean_number(max(0.0, min(100.0, r_squared * 100.0)), 1),
        'explanation': (
            f'The trend model explains about {clean_number(r_squared * 100, 1)}% '
            f'of the historical movement in {target_label}.'
        ),
    }


def multi_factor_regression(
    features: dict[str, Iterable[Any]],
    target: Iterable[Any],
    prediction_inputs: dict[str, float],
    target_label: str,
) -> dict:
    y = _series(target)
    feature_names = list(features.keys())
    columns = [_series(features[name]) for name in feature_names]
    n = min([int(y.size), *[int(col.size) for col in columns]])
    p = len(feature_names)

    if n <= p + 1:
        return {
            'available': False,
            'message': 'Not enough observations for multi-factor regression.',
        }

    y = y[:n]
    x = np.column_stack([col[:n] for col in columns])
    design = np.column_stack([np.ones(n), x])

    try:
        coefficients, *_ = np.linalg.lstsq(design, y, rcond=None)
    except np.linalg.LinAlgError:
        return {
            'available': False,
            'message': 'The regression matrix is unstable for the available data.',
        }

    fitted = design @ coefficients
    ss_res = float(np.sum((y - fitted) ** 2))
    ss_tot = float(np.sum((y - np.mean(y)) ** 2))
    r_squared = 0.0 if ss_tot == 0 else 1.0 - (ss_res / ss_tot)

    pred_vector = [1.0] + [float(prediction_inputs.get(name, 0.0)) for name in feature_names]
    predicted_value = float(np.dot(np.array(pred_vector), coefficients))

    return {
        'available': True,
        'target': target_label,
        'features': feature_names,
        'intercept': clean_number(coefficients[0]),
        'coefficients': {
            name: clean_number(coefficients[i + 1], 6)
            for i, name in enumerate(feature_names)
        },
        'rSquared': clean_number(r_squared),
        'modelReliabilityPct': clean_number(max(0.0, min(100.0, r_squared * 100.0)), 1),
        'predictedValue': clean_number(predicted_value),
        'explanation': (
            f'This model uses {", ".join(feature_names)} together to estimate {target_label}.'
        ),
    }


def empirical_probability(flags: Iterable[bool]) -> float:
    items = list(flags)
    if not items:
        return 0.0
    return float(sum(1 for flag in items if flag) / len(items))


def risk_level_from_probability(probability: float) -> str:
    if probability >= 0.45:
        return 'high'
    if probability >= 0.25:
        return 'medium'
    return 'low'


def p_value_explanation(p_value: float | None) -> str:
    if p_value is None:
        return 'A p-value is not available for this test.'
    if p_value < 0.05:
        return 'The result is statistically significant at the 5% level.'
    return 'The result is not statistically significant at the 5% level.'


def independent_t_test(
    values_a: Iterable[Any],
    values_b: Iterable[Any],
    label_a: str,
    label_b: str,
    metric: str,
) -> dict:
    a = _series(values_a)
    b = _series(values_b)
    if int(a.size) < 2 or int(b.size) < 2:
        return {
            'available': False,
            'test': 'Welch t-test',
            'metric': metric,
            'message': 'Each group needs at least 2 observations for a t-test.',
        }

    result = stats.ttest_ind(a, b, equal_var=False, nan_policy='omit')
    p_value = clean_number(result.pvalue, 6)
    return {
        'available': p_value is not None,
        'test': 'Welch t-test',
        'metric': metric,
        'groupA': label_a,
        'groupB': label_b,
        'meanA': clean_number(np.mean(a)),
        'meanB': clean_number(np.mean(b)),
        'tStatistic': clean_number(result.statistic),
        'pValue': p_value,
        'significant': bool(p_value is not None and p_value < 0.05),
        'explanation': p_value_explanation(p_value),
    }


def one_way_anova(groups: dict[str, Iterable[Any]], metric: str) -> dict:
    cleaned = {name: _series(values) for name, values in groups.items()}
    valid = {name: values for name, values in cleaned.items() if int(values.size) >= 2}
    if len(valid) < 3:
        return {
            'available': False,
            'test': 'One-way ANOVA',
            'metric': metric,
            'message': 'At least 3 groups with 2 observations each are required for ANOVA.',
        }

    result = stats.f_oneway(*valid.values())
    p_value = clean_number(result.pvalue, 6)
    return {
        'available': p_value is not None,
        'test': 'One-way ANOVA',
        'metric': metric,
        'groups': list(valid.keys()),
        'fStatistic': clean_number(result.statistic),
        'pValue': p_value,
        'significant': bool(p_value is not None and p_value < 0.05),
        'explanation': p_value_explanation(p_value),
    }


def chi_square_weather_risk(weather_stress: Iterable[bool], low_yield: Iterable[bool]) -> dict:
    weather = list(weather_stress)
    low = list(low_yield)
    n = min(len(weather), len(low))
    if n < 8:
        return {
            'available': False,
            'test': 'Chi-square test',
            'message': 'At least 8 observations are required for a stable categorical test.',
        }

    table = np.array([
        [
            sum(1 for i in range(n) if weather[i] and low[i]),
            sum(1 for i in range(n) if weather[i] and not low[i]),
        ],
        [
            sum(1 for i in range(n) if not weather[i] and low[i]),
            sum(1 for i in range(n) if not weather[i] and not low[i]),
        ],
    ])

    if np.any(table.sum(axis=0) == 0) or np.any(table.sum(axis=1) == 0):
        return {
            'available': False,
            'test': 'Chi-square test',
            'observedTable': table.tolist(),
            'message': 'The risk categories do not have enough variation for chi-square testing.',
        }

    chi2, p_value_raw, dof, expected = stats.chi2_contingency(table)
    p_value = clean_number(p_value_raw, 6)
    return {
        'available': p_value is not None,
        'test': 'Chi-square test',
        'observedTable': table.tolist(),
        'expectedTable': [[clean_number(v) for v in row] for row in expected.tolist()],
        'chiSquare': clean_number(chi2),
        'degreesOfFreedom': int(dof),
        'pValue': p_value,
        'significant': bool(p_value is not None and p_value < 0.05),
        'explanation': p_value_explanation(p_value),
    }
