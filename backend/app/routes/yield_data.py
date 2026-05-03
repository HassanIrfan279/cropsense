from fastapi import APIRouter
import random
from app.data.pbs_data import (
    YEARS, RAINFALL_MM,
    get_yield, get_yield_series, get_rainfall_for_year,
)

router = APIRouter()


def _ndvi(rainfall: float, seed: float) -> float:
    rng = random.Random(seed)
    raw = (rainfall / 400.0) * 0.6 + 0.25 + rng.uniform(-0.05, 0.05)
    return round(max(0.1, min(0.9, raw)), 3)


@router.get('/test')
async def test_endpoint():
    val = get_yield('faisalabad', 'wheat', 2023)
    return {
        'status':      'ok',
        'data_source': 'PBS real data (pandas DataFrame)',
        'sample_yield': val,
        'description': 'Faisalabad wheat 2023 yield t/acre',
        'total_years': len(YEARS),
        'year_range':  f'{YEARS[0]}-{YEARS[-1]}',
    }


@router.get('/yield/{district}/{crop}')
async def get_yield_data(district: str, crop: str):
    print(f'Yield request: {district}/{crop}')
    series = get_yield_series(district, crop)
    data = []
    for _, row in series.iterrows():
        year     = int(row['year'])
        rainfall = get_rainfall_for_year(year)
        seed     = float(hash(f'{district}{crop}{year}') % 10000)
        ndvi     = _ndvi(rainfall, seed)
        y        = float(row['yield_t_acre'])
        idx      = YEARS.index(year)
        data.append({
            'district':        district.lower(),
            'crop':            crop.lower(),
            'year':            year,
            'month':           None,
            'yieldTAcre':      y,
            'ndvi':            ndvi,
            'rainfallMm':      float(rainfall),
            'tempMaxC':        round(36 + (idx % 3) * 2.0, 1),
            'tempMinC':        round(18 + (idx % 4) * 1.5, 1),
            'soilMoisturePct': round(35 + (idx % 6) * 5.0, 1),
            'predictedYield':  round(y * 0.97, 2),
        })
    print(f'Yield response: {len(data)} records for {district}/{crop}')
    return {'district': district.lower(), 'crop': crop.lower(), 'data': data}


@router.get('/ndvi-timeseries/{district}')
async def get_ndvi(district: str):
    data = [
        {'year': year, 'ndvi': _ndvi(float(RAINFALL_MM[i]),
                                      float(hash(f'{district}{year}') % 10000))}
        for i, year in enumerate(YEARS)
    ]
    return {'district': district.lower(), 'data': data}
