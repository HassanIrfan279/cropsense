from fastapi import APIRouter
import random
import math

router = APIRouter()

@router.get('/yield/{district}/{crop}')
async def get_yield(district: str, crop: str):
    data = []
    for i in range(19):
        yr = 2005 + i
        p = i / 18.0
        base = 1.8 + p * 0.6
        v = 0.3 * (-1 if i % 3 == 0 else 1)
        data.append({
            'district': district,
            'crop': crop,
            'year': yr,
            'month': None,
            'yieldTAcre': round(max(0.8, min(3.5, base + v)), 2),
            'ndvi': round(max(0.2, min(0.9, 0.45 + p * 0.25)), 2),
            'rainfallMm': round(180 + (i % 5) * 40.0, 1),
            'tempMaxC': round(36 + (i % 3) * 2.0, 1),
            'tempMinC': round(18 + (i % 4) * 1.5, 1),
            'soilMoisturePct': round(35 + (i % 6) * 5.0, 1),
            'predictedYield': round(base + v * 0.8, 2),
        })
    return {'district': district, 'crop': crop, 'data': data}

@router.get('/ndvi-timeseries/{district}')
async def get_ndvi(district: str):
    data = []
    for i in range(19):
        p = i / 18.0
        data.append({
            'year': 2005 + i,
            'ndvi': round(max(0.2, min(0.9, 0.45 + p * 0.25)), 3),
        })
    return {'district': district, 'data': data}
