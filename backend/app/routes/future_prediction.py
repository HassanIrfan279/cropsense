from __future__ import annotations

from typing import List, Literal

from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.services.future_prediction import predict_future_crops

router = APIRouter()


class FuturePredictionRequest(BaseModel):
    crops: List[str] = Field(default_factory=lambda: ['wheat'])
    district: str = 'faisalabad'
    farmAcres: float = Field(5.0, ge=0.5, le=1000.0)
    soilType: str = 'loam'
    waterAvailability: str = 'medium'
    budgetPkr: float = Field(150_000.0, ge=0.0)
    predictionYears: Literal[5, 10] = 5


@router.post('/future-prediction')
async def future_prediction(req: FuturePredictionRequest):
    return predict_future_crops(req)
