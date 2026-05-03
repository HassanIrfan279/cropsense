from fastapi import APIRouter, Query
import numpy as np
from scipy import stats as scipy_stats

router = APIRouter()

from app.routes.stats import _compute_stats
from app.data.pbs_data import YEARS, get_yield


def _pct_diff(a: float, b: float) -> float:
    if b == 0:
        return 0.0
    return round((a - b) / abs(b) * 100, 2)


@router.get('/compare')
async def compare_districts(
    district1: str = Query(...),
    district2: str = Query(...),
    crop:      str = Query(...),
):
    s1 = _compute_stats(district1, crop)
    s2 = _compute_stats(district2, crop)

    y1 = np.array([get_yield(district1, crop, yr) for yr in YEARS])
    y2 = np.array([get_yield(district2, crop, yr) for yr in YEARS])

    # Pearson correlation between the two yield series
    pearson_r, pearson_p = scipy_stats.pearsonr(y1, y2)

    # Mann-Whitney U test
    mw_stat, mw_p = scipy_stats.mannwhitneyu(y1, y2, alternative='two-sided')

    # Which district has higher P(yield > 2.0) next season?
    exc_2 = 2.0
    prob1 = float(np.mean(y1 > exc_2))
    prob2 = float(np.mean(y2 > exc_2))
    better_district = district1 if prob1 >= prob2 else district2

    # Percentage differences in key metrics
    pct_diffs = {
        'mean':     _pct_diff(s1['mean'],     s2['mean']),
        'std':      _pct_diff(s1['std'],       s2['std']),
        'trendSlope': _pct_diff(s1['trendSlope'], s2['trendSlope']),
        'droughtProbability': _pct_diff(
            s1['droughtProbability'], s2['droughtProbability']),
        'rSquared': _pct_diff(s1['rSquared'], s2['rSquared']),
    }

    return {
        'crop':           crop.lower(),
        'district1Stats': s1,
        'district2Stats': s2,
        'seriesCorrelation': {
            'pearsonR': round(float(pearson_r), 4),
            'pValue':   round(float(pearson_p), 6),
        },
        'mannWhitney': {
            'statistic':          round(float(mw_stat), 2),
            'pValue':             round(float(mw_p), 6),
            'significantDiff':    bool(mw_p < 0.05),
        },
        'exceedanceProb2t': {
            district1: round(prob1, 4),
            district2: round(prob2, 4),
        },
        'betterDistrict':  better_district,
        'percentageDiffs': pct_diffs,
    }
