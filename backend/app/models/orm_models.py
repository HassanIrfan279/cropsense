from sqlalchemy import Column, String, Float, Integer, DateTime
from sqlalchemy.sql import func
from app.database import Base

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
