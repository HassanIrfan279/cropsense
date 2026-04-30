from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get('/risk-map')
async def get_risk_map():
    return {
        'generatedAt': datetime.now().isoformat(),
        'nationalRiskLevel': 'watch',
        'criticalCount': 2,
        'highCount': 5,
        'watchCount': 8,
        'districts': [
            {'district': 'faisalabad', 'districtName': 'Faisalabad',
             'province': 'Punjab', 'riskLevel': 'watch', 'riskScore': 35.0,
             'ndvi': 0.62, 'alertCount': 1,
             'cropYields': {'wheat': 2.3, 'cotton': 1.9, 'rice': 1.5}},
            {'district': 'lahore', 'districtName': 'Lahore',
             'province': 'Punjab', 'riskLevel': 'good', 'riskScore': 20.0,
             'ndvi': 0.71, 'alertCount': 0,
             'cropYields': {'wheat': 2.7, 'rice': 2.1}},
            {'district': 'multan', 'districtName': 'Multan',
             'province': 'Punjab', 'riskLevel': 'high', 'riskScore': 55.0,
             'ndvi': 0.48, 'alertCount': 3,
             'cropYields': {'wheat': 1.8, 'cotton': 1.4, 'sugarcane': 2.2}},
            {'district': 'karachi', 'districtName': 'Karachi',
             'province': 'Sindh', 'riskLevel': 'high', 'riskScore': 70.0,
             'ndvi': 0.38, 'alertCount': 4,
             'cropYields': {'rice': 1.4, 'sugarcane': 1.8}},
            {'district': 'quetta', 'districtName': 'Quetta',
             'province': 'Balochistan', 'riskLevel': 'critical',
             'riskScore': 82.0, 'ndvi': 0.29, 'alertCount': 6,
             'cropYields': {'wheat': 0.9}},
            {'district': 'peshawar', 'districtName': 'Peshawar',
             'province': 'Khyber Pakhtunkhwa', 'riskLevel': 'above',
             'riskScore': 28.0, 'ndvi': 0.65, 'alertCount': 1,
             'cropYields': {'maize': 2.1, 'wheat': 2.3}},
        ],
    }
