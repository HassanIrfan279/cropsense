from fastapi import APIRouter

router = APIRouter()

@router.get('/stats/{district}')
async def get_stats(district: str):
    crops = ['wheat', 'rice', 'cotton', 'sugarcane', 'maize']
    by_crop = {}
    for crop in crops:
        by_crop[crop] = {
            'district': district,
            'crop': crop,
            'mean': 2.1,
            'median': 2.0,
            'std': 0.4,
            'min': 0.9,
            'max': 3.2,
            'q1': 1.8,
            'q3': 2.5,
            'trendDirection': 'improving',
            'trendSlope': 0.04,
            'pValue': 0.032,
            'rSquared': 0.74,
            'rmse': 0.21,
            'droughtProbability': 0.12,
            'droughtThreshold': 1.2,
            'sampleSize': 19,
            'yearRange': '2005-2023',
        }
    return {'district': district, 'byCrop': by_crop}
