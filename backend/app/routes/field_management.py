from __future__ import annotations

from datetime import date
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.orm_models import (
    ActivityLog,
    FarmerField,
    FertilizerLog,
    FinanceLog,
    IrrigationLog,
    MedicineLog,
    User,
)
from app.services.auth import get_current_user
from app.services.field_management import (
    ai_cost_advice,
    compute_field_analytics,
    create_report,
    field_comparison,
    field_to_dict,
)

router = APIRouter(prefix='/field-management', tags=['field-management'])


class FieldIn(BaseModel):
    fieldName: str = Field(..., min_length=2, max_length=150)
    location: str = Field(..., min_length=2, max_length=180)
    areaSizeAcres: float = Field(..., gt=0, le=5000)
    soilType: str = Field(..., min_length=2, max_length=60)
    crop: str = Field(..., min_length=2, max_length=80)
    sowingDate: Optional[date] = None
    expectedHarvestDate: Optional[date] = None
    waterAvailability: str = Field('medium', max_length=60)
    cropImageUrl: Optional[str] = Field(None, max_length=600)
    notes: Optional[str] = Field(None, max_length=3000)


class IrrigationIn(BaseModel):
    date: date
    waterAmount: float = Field(0.0, ge=0)
    method: str = Field('flood', max_length=100)
    cost: float = Field(0.0, ge=0)
    notes: Optional[str] = Field(None, max_length=2000)


class FertilizerIn(BaseModel):
    date: date
    fertilizerName: str = Field(..., min_length=1, max_length=160)
    fertilizerType: Optional[str] = Field(None, max_length=100)
    quantity: float = Field(0.0, ge=0)
    cost: float = Field(0.0, ge=0)
    purpose: Optional[str] = Field(None, max_length=240)
    notes: Optional[str] = Field(None, max_length=2000)


class MedicineIn(BaseModel):
    date: date
    medicineName: str = Field(..., min_length=1, max_length=180)
    target: Optional[str] = Field(None, max_length=220)
    quantity: float = Field(0.0, ge=0)
    cost: float = Field(0.0, ge=0)
    safetyNotes: Optional[str] = Field(None, max_length=2000)


class ActivityIn(BaseModel):
    date: date
    activityType: str = Field(..., min_length=2, max_length=80)
    description: Optional[str] = Field(None, max_length=300)
    cost: float = Field(0.0, ge=0)
    income: float = Field(0.0, ge=0)
    notes: Optional[str] = Field(None, max_length=2000)


class FinanceIn(BaseModel):
    date: date
    entryType: Literal['expense', 'income']
    category: str = Field(..., min_length=2, max_length=100)
    amount: float = Field(..., gt=0)
    description: Optional[str] = Field(None, max_length=300)
    notes: Optional[str] = Field(None, max_length=2000)


def _field_or_404(db: Session, user: User, field_id: str) -> FarmerField:
    field = (
        db.query(FarmerField)
        .filter(FarmerField.id == field_id, FarmerField.user_id == user.id)
        .first()
    )
    if field is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Field not found.')
    return field


@router.get('/fields')
async def list_fields(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    fields = (
        db.query(FarmerField)
        .filter(FarmerField.user_id == user.id)
        .order_by(FarmerField.created_at.desc())
        .all()
    )
    return {
        'fields': [field_to_dict(field) for field in fields],
        'comparison': field_comparison(db, user),
    }


@router.post('/fields')
async def create_field(
    req: FieldIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    field = FarmerField(
        user_id=user.id,
        field_name=req.fieldName.strip(),
        location=req.location.strip(),
        area_size_acres=req.areaSizeAcres,
        soil_type=req.soilType.lower().strip(),
        crop=req.crop.lower().strip(),
        sowing_date=req.sowingDate,
        expected_harvest_date=req.expectedHarvestDate,
        water_availability=req.waterAvailability.lower().strip(),
        crop_image_url=req.cropImageUrl,
        notes=req.notes,
    )
    db.add(field)
    db.commit()
    db.refresh(field)
    return {'field': field_to_dict(field)}


@router.get('/fields/{field_id}')
async def field_detail(
    field_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    field = _field_or_404(db, user, field_id)
    return {
        'field': field_to_dict(field),
        'analytics': compute_field_analytics(db, user, field),
    }


@router.put('/fields/{field_id}')
async def update_field(
    field_id: str,
    req: FieldIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    field = _field_or_404(db, user, field_id)
    field.field_name = req.fieldName.strip()
    field.location = req.location.strip()
    field.area_size_acres = req.areaSizeAcres
    field.soil_type = req.soilType.lower().strip()
    field.crop = req.crop.lower().strip()
    field.sowing_date = req.sowingDate
    field.expected_harvest_date = req.expectedHarvestDate
    field.water_availability = req.waterAvailability.lower().strip()
    field.crop_image_url = req.cropImageUrl
    field.notes = req.notes
    db.commit()
    db.refresh(field)
    return {'field': field_to_dict(field)}


@router.delete('/fields/{field_id}')
async def delete_field(
    field_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    field = _field_or_404(db, user, field_id)
    for model in [IrrigationLog, FertilizerLog, MedicineLog, ActivityLog, FinanceLog]:
        db.query(model).filter(model.user_id == user.id, model.field_id == field_id).delete()
    db.delete(field)
    db.commit()
    return {'deleted': True, 'fieldId': field_id}


@router.post('/fields/{field_id}/irrigation')
async def add_irrigation(
    field_id: str,
    req: IrrigationIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _field_or_404(db, user, field_id)
    row = IrrigationLog(
        user_id=user.id,
        field_id=field_id,
        log_date=req.date,
        water_amount=req.waterAmount,
        method=req.method,
        cost=req.cost,
        notes=req.notes,
    )
    db.add(row)
    db.commit()
    return {'created': True, 'id': row.id}


@router.post('/fields/{field_id}/fertilizer')
async def add_fertilizer(
    field_id: str,
    req: FertilizerIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _field_or_404(db, user, field_id)
    row = FertilizerLog(
        user_id=user.id,
        field_id=field_id,
        log_date=req.date,
        fertilizer_name=req.fertilizerName,
        fertilizer_type=req.fertilizerType,
        quantity=req.quantity,
        cost=req.cost,
        purpose=req.purpose,
        notes=req.notes,
    )
    db.add(row)
    db.commit()
    return {'created': True, 'id': row.id}


@router.post('/fields/{field_id}/medicine')
async def add_medicine(
    field_id: str,
    req: MedicineIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _field_or_404(db, user, field_id)
    row = MedicineLog(
        user_id=user.id,
        field_id=field_id,
        log_date=req.date,
        medicine_name=req.medicineName,
        target=req.target,
        quantity=req.quantity,
        cost=req.cost,
        safety_notes=req.safetyNotes,
    )
    db.add(row)
    db.commit()
    return {'created': True, 'id': row.id}


@router.post('/fields/{field_id}/activities')
async def add_activity(
    field_id: str,
    req: ActivityIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _field_or_404(db, user, field_id)
    row = ActivityLog(
        user_id=user.id,
        field_id=field_id,
        log_date=req.date,
        activity_type=req.activityType,
        description=req.description,
        cost=req.cost,
        income=req.income,
        notes=req.notes,
    )
    db.add(row)
    db.commit()
    return {'created': True, 'id': row.id}


@router.post('/fields/{field_id}/finance')
async def add_finance(
    field_id: str,
    req: FinanceIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _field_or_404(db, user, field_id)
    row = FinanceLog(
        user_id=user.id,
        field_id=field_id,
        log_date=req.date,
        entry_type=req.entryType,
        category=req.category,
        amount=req.amount,
        description=req.description,
        notes=req.notes,
    )
    db.add(row)
    db.commit()
    return {'created': True, 'id': row.id}


@router.get('/fields/{field_id}/analytics')
async def field_analytics(
    field_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    field = _field_or_404(db, user, field_id)
    return {
        'analytics': compute_field_analytics(db, user, field),
        'comparison': field_comparison(db, user),
    }


@router.get('/fields/{field_id}/ai-cost-advice')
async def field_ai_cost_advice(
    field_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    field = _field_or_404(db, user, field_id)
    analytics = compute_field_analytics(db, user, field)
    return {'advice': await ai_cost_advice(field, analytics)}


@router.get('/fields/{field_id}/report')
async def field_report(
    field_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    field = _field_or_404(db, user, field_id)
    analytics = compute_field_analytics(db, user, field)
    advice = await ai_cost_advice(field, analytics)
    return {'report': create_report(db, user, field, analytics, advice)}
