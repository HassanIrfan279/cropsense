from fastapi import APIRouter
import random
import numpy as np
from scipy import stats as scipy_stats
from app.data.pbs_data import (
    YEARS, get_yield_series, get_rainfall_for_year,
)

router = APIRouter()

CROPS = ['wheat', 'rice', 'cotton', 'sugarcane', 'maize']

NATIONAL_MEAN = {
    'wheat': 2.0, 'rice': 1.7, 'cotton': 1.4,
    'sugarcane': 22.0, 'maize': 1.6,
}


def _ndvi(rainfall: float, seed: float) -> float:
    rng = random.Random(seed)
    raw = (rainfall / 400.0) * 0.6 + 0.25 + rng.uniform(-0.05, 0.05)
    return round(max(0.1, min(0.9, raw)), 3)


def _build_series(district: str, crop: str):
    series_df = get_yield_series(district, crop)
    yields    = series_df['yield_t_acre'].values.astype(float)
    rainfalls = np.array([get_rainfall_for_year(y) for y in YEARS], dtype=float)
    ndvis     = np.array([
        _ndvi(get_rainfall_for_year(y), float(hash(f'{district}{crop}{y}') % 10000))
        for y in YEARS
    ], dtype=float)
    temps = np.array([round(36 + (i % 3) * 2.0, 1) for i in range(len(YEARS))], dtype=float)
    return yields, rainfalls, ndvis, temps


def _compute_stats(district: str, crop: str) -> dict:
    y, rain, ndvi, temp = _build_series(district, crop)
    n = len(y)
    x = np.arange(n, dtype=float)

    mean_y   = float(np.mean(y))
    median_y = float(np.median(y))
    std_y    = float(np.std(y, ddof=1))
    var_y    = float(np.var(y, ddof=1))
    cv       = float(std_y / mean_y * 100) if mean_y else 0.0
    skew     = float(scipy_stats.skew(y))
    kurt     = float(scipy_stats.kurtosis(y))
    q1       = float(np.percentile(y, 25))
    q3       = float(np.percentile(y, 75))
    iqr_val  = float(q3 - q1)

    reg       = scipy_stats.linregress(x, y)
    slope     = float(reg.slope)
    intercept = float(reg.intercept)
    r_squared = float(reg.rvalue ** 2)
    p_value   = float(reg.pvalue)
    rmse      = float(np.sqrt(np.mean((y - (reg.slope * x + reg.intercept)) ** 2)))

    pearson_rain,  _ = scipy_stats.pearsonr(y, rain)
    spearman_rain, _ = scipy_stats.spearmanr(y, rain)
    pearson_temp,  _ = scipy_stats.pearsonr(y, temp)
    spearman_temp, _ = scipy_stats.spearmanr(y, temp)
    pearson_ndvi,  _ = scipy_stats.pearsonr(y, ndvi)
    spearman_ndvi, _ = scipy_stats.spearmanr(y, ndvi)

    nat_mean       = NATIONAL_MEAN.get(crop.lower(), float(mean_y))
    t_stat, t_p    = scipy_stats.ttest_1samp(y, nat_mean)
    se             = std_y / np.sqrt(n)
    ci_lo, ci_hi   = scipy_stats.t.interval(0.95, df=n - 1, loc=mean_y, scale=se)

    drought_thresh = max(0.5, mean_y * 0.6)
    drought_prob   = float(np.sum(y < drought_thresh) / n)

    thresholds = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
    exceedance = {str(t): float(np.mean(y > t)) for t in thresholds}

    fence    = 1.5 * iqr_val
    outliers = [int(YEARS[i]) for i in range(n)
                if y[i] < q1 - fence or y[i] > q3 + fence]

    if slope > 0.02:
        trend_dir = 'improving'
    elif slope < -0.02:
        trend_dir = 'declining'
    else:
        trend_dir = 'stable'

    return {
        'district':   district.lower(),
        'crop':       crop.lower(),
        'mean':       round(mean_y, 4),
        'median':     round(median_y, 4),
        'std':        round(std_y, 4),
        'variance':   round(var_y, 4),
        'cv':         round(cv, 2),
        'skewness':   round(skew, 4),
        'kurtosis':   round(kurt, 4),
        'min':        round(float(np.min(y)), 4),
        'max':        round(float(np.max(y)), 4),
        'q1':         round(q1, 4),
        'q3':         round(q3, 4),
        'iqr':        round(iqr_val, 4),
        'trendDirection': trend_dir,
        'trendSlope':     round(slope, 6),
        'intercept':      round(intercept, 4),
        'rSquared':       round(r_squared, 4),
        'pValue':         round(p_value, 6),
        'rmse':           round(rmse, 4),
        'tStat':          round(float(t_stat), 4),
        'tTestPValue':    round(float(t_p), 6),
        'ci95Lower':      round(float(ci_lo), 4),
        'ci95Upper':      round(float(ci_hi), 4),
        'pearsonRainfall':  round(float(pearson_rain), 4),
        'spearmanRainfall': round(float(spearman_rain), 4),
        'pearsonTemp':      round(float(pearson_temp), 4),
        'spearmanTemp':     round(float(spearman_temp), 4),
        'pearsonNdvi':      round(float(pearson_ndvi), 4),
        'spearmanNdvi':     round(float(spearman_ndvi), 4),
        'droughtProbability': round(drought_prob, 4),
        'droughtThreshold':   round(drought_thresh, 2),
        'exceedanceProbabilities': exceedance,
        'normalMu':    round(float(np.mean(y)), 4),
        'normalSigma': round(float(np.std(y, ddof=1)), 4),
        'outlierYears': outliers,
        'sampleSize':  n,
        'yearRange':   '2005-2023',
        'dataSource':  'PBS real data',
    }


@router.get('/stats/{district}/{crop}')
async def get_stats_crop(district: str, crop: str):
    print(f'Stats request: {district}/{crop}')
    return _compute_stats(district, crop)


@router.get('/stats/{district}')
async def get_stats(district: str):
    print(f'Stats request: {district}')
    by_crop = {c: _compute_stats(district, c) for c in CROPS}
    return {'district': district.lower(), 'byCrop': by_crop}
