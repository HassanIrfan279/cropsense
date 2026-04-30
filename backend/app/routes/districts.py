from fastapi import APIRouter, Depends
from app.models.orm_models import District

router = APIRouter()

MOCK_DISTRICTS = [
    {'id': 'faisalabad', 'name': 'Faisalabad', 'province': 'Punjab',
     'lat': 31.4504, 'lng': 73.1350, 'riskScore': 35.0, 'riskLevel': 'watch',
     'currentNdvi': 0.62, 'currentYieldForecast': 2.3,
     'confidenceLow': 2.0, 'confidenceHigh': 2.6, 'forecastCrop': 'wheat'},
    {'id': 'lahore', 'name': 'Lahore', 'province': 'Punjab',
     'lat': 31.5497, 'lng': 74.3436, 'riskScore': 20.0, 'riskLevel': 'good',
     'currentNdvi': 0.71, 'currentYieldForecast': 2.7,
     'confidenceLow': 2.4, 'confidenceHigh': 3.0, 'forecastCrop': 'wheat'},
    {'id': 'multan', 'name': 'Multan', 'province': 'Punjab',
     'lat': 30.1978, 'lng': 71.4711, 'riskScore': 55.0, 'riskLevel': 'high',
     'currentNdvi': 0.48, 'currentYieldForecast': 1.8,
     'confidenceLow': 1.5, 'confidenceHigh': 2.1, 'forecastCrop': 'cotton'},
    {'id': 'karachi', 'name': 'Karachi', 'province': 'Sindh',
     'lat': 24.8607, 'lng': 67.0011, 'riskScore': 70.0, 'riskLevel': 'high',
     'currentNdvi': 0.38, 'currentYieldForecast': 1.4,
     'confidenceLow': 1.1, 'confidenceHigh': 1.7, 'forecastCrop': 'rice'},
    {'id': 'quetta', 'name': 'Quetta', 'province': 'Balochistan',
     'lat': 30.1798, 'lng': 66.9750, 'riskScore': 82.0, 'riskLevel': 'critical',
     'currentNdvi': 0.29, 'currentYieldForecast': 0.9,
     'confidenceLow': 0.6, 'confidenceHigh': 1.2, 'forecastCrop': 'wheat'},
    {'id': 'peshawar', 'name': 'Peshawar', 'province': 'Khyber Pakhtunkhwa',
     'lat': 34.0151, 'lng': 71.5249, 'riskScore': 28.0, 'riskLevel': 'above',
     'currentNdvi': 0.65, 'currentYieldForecast': 2.1,
     'confidenceLow': 1.9, 'confidenceHigh': 2.4, 'forecastCrop': 'maize'},
]

@router.get('/districts')
async def get_districts():
    try:
        return {'districts': MOCK_DISTRICTS}
    except Exception as e:
        return {'districts': MOCK_DISTRICTS}

@router.get('/provinces')
async def get_provinces():
    return {'provinces': [
        {'name': 'Punjab', 'avgYield': 2.4, 'ndvi': 0.64,
         'riskLevel': 'watch', 'alertCount': 6, 'districtCount': 14},
        {'name': 'Sindh', 'avgYield': 1.9, 'ndvi': 0.51,
         'riskLevel': 'high', 'alertCount': 5, 'districtCount': 8},
        {'name': 'Khyber Pakhtunkhwa', 'avgYield': 2.1, 'ndvi': 0.68,
         'riskLevel': 'above', 'alertCount': 2, 'districtCount': 6},
        {'name': 'Balochistan', 'avgYield': 1.2, 'ndvi': 0.31,
         'riskLevel': 'critical', 'alertCount': 7, 'districtCount': 8},
    ]}
