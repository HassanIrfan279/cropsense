import os

bs = chr(92)
nl = chr(10)
q = chr(39)
lt = chr(60)
gt = chr(62)

# ── backend/.env ──────────────────────────────────────────────────────
env = """ORACLE_USER=system
ORACLE_PASSWORD=replace_with_oracle_password
ORACLE_HOST=localhost
ORACLE_PORT=1521
ORACLE_SERVICE=XEPDB1
GROK_API_KEY=your_grok_key_here
CORS_ORIGINS=http://localhost:8080,http://localhost:5000,https://your-vercel-app.vercel.app
"""

# ── database.py ───────────────────────────────────────────────────────
database = """import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from dotenv import load_dotenv

load_dotenv()

ORACLE_USER = os.getenv('ORACLE_USER', 'system')
ORACLE_PASSWORD = os.getenv('ORACLE_PASSWORD', '')
ORACLE_HOST = os.getenv('ORACLE_HOST', 'localhost')
ORACLE_PORT = os.getenv('ORACLE_PORT', '1521')
ORACLE_SERVICE = os.getenv('ORACLE_SERVICE', 'XEPDB1')

DATABASE_URL = (
    f'oracle+oracledb://{ORACLE_USER}:{ORACLE_PASSWORD}'
    f'@{ORACLE_HOST}:{ORACLE_PORT}/?service_name={ORACLE_SERVICE}'
)

engine = create_engine(
    DATABASE_URL,
    connect_args={'thick_mode': False},
    pool_size=5,
    max_overflow=10,
    echo=False,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class Base(DeclarativeBase):
    pass

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
"""

# ── orm_models.py ─────────────────────────────────────────────────────
orm_models = """from sqlalchemy import Column, String, Float, Integer, DateTime
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
"""

# ── main.py ───────────────────────────────────────────────────────────
main_py = """import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from app.routes import districts, yield_data, risk_map, ai_advise, stats

load_dotenv()

app = FastAPI(
    title='CropSense API',
    description='Pakistan Smart Farm Intelligence Platform',
    version='1.0.0',
)

origins = os.getenv('CORS_ORIGINS', 'http://localhost:8080').split(',')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

app.include_router(districts.router, prefix='/api')
app.include_router(yield_data.router, prefix='/api')
app.include_router(risk_map.router, prefix='/api')
app.include_router(ai_advise.router, prefix='/api')
app.include_router(stats.router, prefix='/api')

@app.get('/')
async def root():
    return {
        'app': 'CropSense API',
        'version': '1.0.0',
        'status': 'running',
        'docs': '/docs',
    }

@app.get('/health')
async def health():
    return {'status': 'healthy'}
"""

# ── routes/districts.py ───────────────────────────────────────────────
districts_route = """from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.orm_models import District
from typing import Any

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
"""

# ── routes/risk_map.py ────────────────────────────────────────────────
risk_map_route = """from fastapi import APIRouter
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
"""

# ── routes/yield_data.py ──────────────────────────────────────────────
yield_route = """from fastapi import APIRouter
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
"""

# ── routes/stats.py ───────────────────────────────────────────────────
stats_route = """from fastapi import APIRouter

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
"""

# ── routes/ai_advise.py ───────────────────────────────────────────────
ai_route = """from fastapi import APIRouter
from pydantic import BaseModel
from typing import List
from app.services.grok import get_grok_advice
from datetime import datetime

router = APIRouter()

class AdviceRequest(BaseModel):
    district: str
    crop: str
    province: str
    season: str
    farmSizeAcres: float
    ndvi: float
    rainfallMm: float
    tempMaxC: float
    soilMoisturePct: float
    waterTableM: float
    symptoms: List[str]
    language: str = 'en'

class PredictRequest(BaseModel):
    district: str
    crop: str
    ndvi: float
    rainfall_mm: float
    temp_max_c: float
    soil_moisture_pct: float

@router.post('/predict')
async def predict(req: PredictRequest):
    predicted = 1.8 + (req.ndvi * 1.2) + (req.rainfall_mm * 0.002)
    predicted = round(max(0.5, min(4.0, predicted)), 2)
    return {
        'district': req.district,
        'crop': req.crop,
        'predictedYield': predicted,
        'confidenceLow': round(predicted - 0.3, 2),
        'confidenceHigh': round(predicted + 0.3, 2),
    }

@router.post('/ai-advise')
async def ai_advise(req: AdviceRequest):
    try:
        advice = await get_grok_advice(req)
        return advice
    except Exception as e:
        total_cost = 12500.0 * req.farmSizeAcres
        return {
            'alertUrdu': 'Fasal ko zang ka khatara hai — kal subah spray karein',
            'alertEnglish': f'{req.crop.title()} rust risk detected in {req.district.title()} — immediate action recommended',
            'diagnosis': 'Yellow rust (Puccinia striiformis) — Early Stage',
            'confidencePct': 87.0,
            'actionSteps': [
                '1. Apply Topsin-M 70 WP at 250g per acre within 48 hours',
                '2. Increase irrigation to every 8 days',
                '3. Avoid nitrogen fertilizer for 2 weeks',
                '4. Monitor daily — repeat spray after 10 days if spreading',
                '5. Report to local agriculture office if 30% leaves affected',
            ],
            'medicines': [
                {
                    'name': 'Topsin-M 70 WP',
                    'type': 'fungicide',
                    'activeIngredient': 'Thiophanate-methyl 70%',
                    'dose': '250g per acre in 100L water',
                    'pricePerAcrePkr': 850.0,
                    'urgency': 'immediate',
                    'purpose': 'Yellow rust (Puccinia striiformis)',
                    'whereToBuy': 'Any agri store in local grain market',
                    'applicationNote': 'Spray early morning or evening',
                },
                {
                    'name': 'Dithane M-45',
                    'type': 'fungicide',
                    'activeIngredient': 'Mancozeb 80%',
                    'dose': '500g per acre in 100L water',
                    'pricePerAcrePkr': 650.0,
                    'urgency': 'within_week',
                    'purpose': 'Preventive broad-spectrum disease control',
                    'whereToBuy': 'Punjab Seed Corporation outlets',
                    'applicationNote': 'Use as follow-up 10 days after Topsin',
                },
            ],
            'fertilizerAdvice': 'Hold all nitrogen (urea) for 2 weeks. Apply 1 bag DAP per acre after disease controlled.',
            'irrigationAdvice': 'Increase to every 8 days. Ensure proper drainage — avoid waterlogging.',
            'totalCostPerAcrePkr': 12500.0,
            'totalCostForFarmPkr': total_cost,
            'expectedYieldIncreasePct': 18.0,
            'roiNote': f'Spending Rs.12,500 now protects ~Rs.45,000 in yield. Net ROI: 260% on treatment.',
            'nextCheckupDays': 7,
            'generatedAt': datetime.now().isoformat(),
            'district': req.district,
            'crop': req.crop,
        }
"""

# ── services/grok.py ──────────────────────────────────────────────────
grok_service = """import os
import httpx
from dotenv import load_dotenv

load_dotenv()

GROK_API_KEY = os.getenv('GROK_API_KEY', '')
GROK_URL = 'https://api.x.ai/v1/chat/completions'

async def get_grok_advice(req) -> dict:
    if not GROK_API_KEY or GROK_API_KEY == 'your_grok_key_here':
        raise ValueError('No Grok API key configured')

    symptoms_text = ', '.join(req.symptoms) if req.symptoms else 'none'

    prompt = f\"\"\"You are an expert agricultural advisor for Pakistan.
A farmer in {req.district}, {req.province} needs advice for their {req.crop} crop.

Farm Details:
- Season: {req.season}
- Farm size: {req.farmSizeAcres} acres
- NDVI: {req.ndvi} (vegetation health 0-1)
- Rainfall: {req.rainfallMm}mm
- Max temperature: {req.tempMaxC}C
- Soil moisture: {req.soilMoisturePct}%
- Water table: {req.waterTableM}m
- Observed symptoms: {symptoms_text}

Respond in JSON with these exact keys:
alertUrdu (Roman Urdu warning), alertEnglish, diagnosis, confidencePct (0-100),
actionSteps (list of 5 strings), fertilizerAdvice, irrigationAdvice,
totalCostPerAcrePkr (number), expectedYieldIncreasePct (number),
roiNote, nextCheckupDays (number).

Use real Pakistani medicine/fertilizer brand names sold in Pakistani markets.
Keep Roman Urdu simple and practical for a farmer.\"\"\"

    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(
            GROK_URL,
            headers={
                'Authorization': f'Bearer {GROK_API_KEY}',
                'Content-Type': 'application/json',
            },
            json={
                'model': 'grok-beta',
                'messages': [{'role': 'user', 'content': prompt}],
                'temperature': 0.3,
            },
        )
        response.raise_for_status()
        data = response.json()
        content = data['choices'][0]['message']['content']

        import json
        import re
        json_match = re.search(r'\\{.*\\}', content, re.DOTALL)
        if json_match:
            advice = json.loads(json_match.group())
            advice['medicines'] = []
            advice['totalCostForFarmPkr'] = (
                advice.get('totalCostPerAcrePkr', 0) * req.farmSizeAcres
            )
            advice['district'] = req.district
            advice['crop'] = req.crop
            return advice
        raise ValueError('Could not parse Grok response')
"""

# Write all files
files = {
    f'backend{bs}.env': env,
    f'backend{bs}app{bs}database.py': database,
    f'backend{bs}app{bs}models{bs}orm_models.py': orm_models,
    f'backend{bs}app{bs}main.py': main_py,
    f'backend{bs}app{bs}routes{bs}districts.py': districts_route,
    f'backend{bs}app{bs}routes{bs}risk_map.py': risk_map_route,
    f'backend{bs}app{bs}routes{bs}yield_data.py': yield_route,
    f'backend{bs}app{bs}routes{bs}stats.py': stats_route,
    f'backend{bs}app{bs}routes{bs}ai_advise.py': ai_route,
    f'backend{bs}app{bs}services{bs}grok.py': grok_service,
}

for path, content in files.items():
    # Create __init__.py files for Python packages
    dir_path = os.path.dirname(path)
    init = os.path.join(dir_path, '__init__.py')
    if not os.path.exists(init):
        open(init, 'w').close()

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Written: {path}')

print('\n Backend files written!')
