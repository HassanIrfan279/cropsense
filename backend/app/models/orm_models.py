import uuid

from sqlalchemy import Column, String, Float, Integer, DateTime, Boolean, Date, ForeignKey, Text
from sqlalchemy.sql import func
from app.database import Base


def _uuid() -> str:
    return str(uuid.uuid4())

class District(Base):
    __tablename__ = 'cs_districts'
    id = Column(String(50), primary_key=True)
    name = Column(String(100), nullable=False)
    province = Column(String(100), nullable=False)
    lat = Column(Float, nullable=False)
    lng = Column(Float, nullable=False)
    risk_score = Column(Float, default=0.0)
    risk_level = Column(String(20), default='good')
    current_ndvi = Column(Float, default=0.0)
    current_yield_forecast = Column(Float, default=0.0)
    confidence_low = Column(Float, default=0.0)
    confidence_high = Column(Float, default=0.0)
    forecast_crop = Column(String(50), default='wheat')
    updated_at = Column(DateTime, server_default=func.now())

class YieldRecord(Base):
    __tablename__ = 'cs_yield_records'
    id = Column(Integer, primary_key=True, autoincrement=True)
    district = Column(String(50), nullable=False)
    crop = Column(String(50), nullable=False)
    year = Column(Integer, nullable=False)
    month = Column(Integer)
    yield_t_acre = Column(Float, nullable=False)
    ndvi = Column(Float)
    rainfall_mm = Column(Float)
    temp_max_c = Column(Float)
    temp_min_c = Column(Float)
    soil_moisture_pct = Column(Float)
    predicted_yield = Column(Float)

class RiskMapEntry(Base):
    __tablename__ = 'cs_risk_map'
    district = Column(String(50), primary_key=True)
    district_name = Column(String(100))
    province = Column(String(100))
    risk_level = Column(String(20), default='good')
    risk_score = Column(Float, default=0.0)
    ndvi = Column(Float, default=0.0)
    alert_count = Column(Integer, default=0)
    wheat_yield = Column(Float, default=0.0)
    rice_yield = Column(Float, default=0.0)
    cotton_yield = Column(Float, default=0.0)
    sugarcane_yield = Column(Float, default=0.0)
    maize_yield = Column(Float, default=0.0)
    generated_at = Column(DateTime, server_default=func.now())


class User(Base):
    __tablename__ = 'cs_users'
    id = Column(String(36), primary_key=True, default=_uuid)
    email = Column(String(255), nullable=False, unique=True, index=True)
    username = Column(String(120), nullable=False)
    password_hash = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())


class FarmerField(Base):
    __tablename__ = 'cs_farmer_fields'
    id = Column(String(36), primary_key=True, default=_uuid)
    user_id = Column(String(36), ForeignKey('cs_users.id'), nullable=False, index=True)
    field_name = Column(String(150), nullable=False)
    location = Column(String(180), nullable=False)
    area_size_acres = Column(Float, nullable=False)
    soil_type = Column(String(60), nullable=False)
    crop = Column(String(80), nullable=False)
    sowing_date = Column(Date)
    expected_harvest_date = Column(Date)
    water_availability = Column(String(60), default='medium')
    crop_image_url = Column(String(600))
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())


class IrrigationLog(Base):
    __tablename__ = 'cs_irrigation_logs'
    id = Column(String(36), primary_key=True, default=_uuid)
    user_id = Column(String(36), ForeignKey('cs_users.id'), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey('cs_farmer_fields.id'), nullable=False, index=True)
    log_date = Column(Date, nullable=False)
    water_amount = Column(Float, default=0.0)
    method = Column(String(100), default='flood')
    cost = Column(Float, default=0.0)
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())


class FertilizerLog(Base):
    __tablename__ = 'cs_fertilizer_logs'
    id = Column(String(36), primary_key=True, default=_uuid)
    user_id = Column(String(36), ForeignKey('cs_users.id'), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey('cs_farmer_fields.id'), nullable=False, index=True)
    log_date = Column(Date, nullable=False)
    fertilizer_name = Column(String(160), nullable=False)
    fertilizer_type = Column(String(100))
    quantity = Column(Float, default=0.0)
    cost = Column(Float, default=0.0)
    purpose = Column(String(240))
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())


class MedicineLog(Base):
    __tablename__ = 'cs_medicine_logs'
    id = Column(String(36), primary_key=True, default=_uuid)
    user_id = Column(String(36), ForeignKey('cs_users.id'), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey('cs_farmer_fields.id'), nullable=False, index=True)
    log_date = Column(Date, nullable=False)
    medicine_name = Column(String(180), nullable=False)
    target = Column(String(220))
    quantity = Column(Float, default=0.0)
    cost = Column(Float, default=0.0)
    safety_notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())


class ActivityLog(Base):
    __tablename__ = 'cs_activity_logs'
    id = Column(String(36), primary_key=True, default=_uuid)
    user_id = Column(String(36), ForeignKey('cs_users.id'), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey('cs_farmer_fields.id'), nullable=False, index=True)
    log_date = Column(Date, nullable=False)
    activity_type = Column(String(80), nullable=False)
    description = Column(String(300))
    cost = Column(Float, default=0.0)
    income = Column(Float, default=0.0)
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())


class FinanceLog(Base):
    __tablename__ = 'cs_finance_logs'
    id = Column(String(36), primary_key=True, default=_uuid)
    user_id = Column(String(36), ForeignKey('cs_users.id'), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey('cs_farmer_fields.id'), nullable=False, index=True)
    log_date = Column(Date, nullable=False)
    entry_type = Column(String(20), nullable=False)
    category = Column(String(100), nullable=False)
    amount = Column(Float, nullable=False)
    description = Column(String(300))
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())


class FieldReport(Base):
    __tablename__ = 'cs_field_reports'
    id = Column(String(36), primary_key=True, default=_uuid)
    user_id = Column(String(36), ForeignKey('cs_users.id'), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey('cs_farmer_fields.id'), nullable=False, index=True)
    title = Column(String(180), nullable=False)
    report_json = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
