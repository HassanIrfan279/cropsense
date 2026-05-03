from fastapi import APIRouter, Query

from app.data.pbs_data import YEARS
from app.services.risk_map_service import build_risk_map

router = APIRouter()


@router.get('/risk-map')
async def get_risk_map(
    crop: str = Query('wheat', description='Crop id, e.g. wheat/rice/cotton/sugarcane/maize'),
    year: int = Query(2023, ge=min(YEARS), le=max(YEARS)),
):
    return build_risk_map(crop=crop, year=year)
