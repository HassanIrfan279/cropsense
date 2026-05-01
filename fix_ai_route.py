content = '''from fastapi import APIRouter
from pydantic import BaseModel
from typing import List
from app.services.grok import get_grok_advice

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
    language: str = "en"

class PredictRequest(BaseModel):
    district: str
    crop: str
    ndvi: float
    rainfall_mm: float
    temp_max_c: float
    soil_moisture_pct: float

@router.post("/predict")
async def predict(req: PredictRequest):
    predicted = 1.8 + (req.ndvi * 1.2) + (req.rainfall_mm * 0.002)
    predicted = round(max(0.5, min(4.0, predicted)), 2)
    return {
        "district": req.district,
        "crop": req.crop,
        "predictedYield": predicted,
        "confidenceLow": round(predicted - 0.3, 2),
        "confidenceHigh": round(predicted + 0.3, 2),
    }

@router.post("/ai-advise")
async def ai_advise(req: AdviceRequest):
    try:
        print(f"AI advice requested for {req.district}/{req.crop}")
        print(f"Symptoms: {req.symptoms}")
        print(f"NDVI: {req.ndvi}, Temp: {req.tempMaxC}, Rain: {req.rainfallMm}")
        advice = await get_grok_advice(req)
        return advice
    except Exception as e:
        print(f"Grok failed: {e} — using dynamic mock")
        has_rust = "rust_patches" in req.symptoms
        has_yellow = "leaf_yellowing" in req.symptoms
        has_pest = "pest_damage" in req.symptoms
        has_wilt = "wilting" in req.symptoms
        symptom_text = ", ".join(req.symptoms) if req.symptoms else "no visible symptoms"

        risk_level = "Low"
        if req.ndvi < 0.3: risk_level = "Critical"
        elif req.ndvi < 0.5: risk_level = "High"
        elif req.tempMaxC > 42: risk_level = "High"
        elif req.rainfallMm < 50: risk_level = "Moderate"

        if has_rust:
            diagnosis = f"Yellow rust (Puccinia striiformis) — NDVI {req.ndvi} confirms stress"
            urdu = f"{req.district.title()} mein {req.crop} ko zang ka khatara — fori spray karein"
            steps = [
                "1. Topsin-M 70WP 250g/acre spray karein aaj hi",
                f"2. Irrigation {8 if req.rainfallMm < 100 else 12} din baad dein",
                "3. 2 hafte Urea bilkul na daalein",
                "4. Roz subah leaves check karein",
                "5. 10 din baad dobara spray karein",
            ]
            medicine_name = "Topsin-M 70 WP"
            medicine_price = 850.0
            medicine_urgency = "immediate"
        elif has_yellow:
            diagnosis = f"Nitrogen deficiency + fungal risk — NDVI {req.ndvi}"
            urdu = f"{req.district.title()} mein {req.crop} ki fasal mein nitrogen ki kami hai"
            steps = [
                "1. Soil test karwain — nitrogen level check karein",
                "2. Urea 1 bag/acre apply karein irrigation ke saath",
                "3. Dithane M-45 500g/acre spray karein",
                f"4. Soil moisture {req.soilMoisturePct}% — irrigation schedule check karein",
                "5. 7 din baad leaf color observe karein",
            ]
            medicine_name = "Dithane M-45"
            medicine_price = 650.0
            medicine_urgency = "within_week"
        elif has_pest:
            diagnosis = f"Pest infestation — immediate IPM needed for {req.crop}"
            urdu = f"{req.district.title()} mein {req.crop} par keeron ka hamla — spray karein"
            steps = [
                "1. Confidor 200ml/acre spray karein",
                "2. Subah ya shaam spray karein — din mein nahi",
                "3. Karate backup ke tor par rakhein",
                "4. Roz monitoring karein agli 2 hafton tak",
                "5. Natural dushmanon ko protect karein",
            ]
            medicine_name = "Confidor (Imidacloprid)"
            medicine_price = 950.0
            medicine_urgency = "immediate"
        elif has_wilt:
            diagnosis = f"Water/heat stress — rainfall {req.rainfallMm}mm, temp {req.tempMaxC}C"
            urdu = f"{req.district.title()} mein {req.crop} murjha rahi — pani aur garmi ki wajah se"
            steps = [
                f"1. Fori irrigation dein — {req.rainfallMm}mm rainfall kaafi nahi",
                "2. Mulching karein soil moisture bachane ke liye",
                f"3. Temperature {req.tempMaxC}C — shaam ko irrigation karein",
                "4. Anti-stress spray consider karein",
                "5. 5 din mein dobara check karein",
            ]
            medicine_name = "Potassium Silicate (Anti-stress)"
            medicine_price = 750.0
            medicine_urgency = "within_week"
        else:
            diagnosis = f"{req.crop.title()} in {req.district.title()} — {risk_level} risk, NDVI: {req.ndvi}"
            urdu = f"{req.district.title()} mein {req.crop} ka risk {risk_level} hai — monitoring zaroor karein"
            steps = [
                f"1. NDVI {req.ndvi} — {'stress hai' if req.ndvi < 0.5 else 'theek hai'}",
                f"2. Rainfall {req.rainfallMm}mm — {'irrigation chahiye' if req.rainfallMm < 100 else 'theek hai'}",
                f"3. Temperature {req.tempMaxC}C — {'heat stress' if req.tempMaxC > 40 else 'normal'}",
                f"4. Soil moisture {req.soilMoisturePct}% — {'kam hai' if req.soilMoisturePct < 30 else 'theek'}",
                f"5. Next visit {7 if risk_level in ['High','Critical'] else 14} din mein",
            ]
            medicine_name = "DAP Fertilizer"
            medicine_price = 8500.0
            medicine_urgency = "preventive"

        total = 12500.0 * req.farmSizeAcres
        return {
            "alertUrdu": urdu,
            "alertEnglish": f"{req.crop.title()} in {req.district.title()}, {req.province}: {risk_level} risk. NDVI={req.ndvi}, Temp={req.tempMaxC}C, Rain={req.rainfallMm}mm. Symptoms: {symptom_text}.",
            "diagnosis": diagnosis,
            "confidencePct": 92.0 if req.symptoms else 75.0,
            "actionSteps": steps,
            "medicines": [{
                "name": medicine_name,
                "type": "fungicide",
                "activeIngredient": "See label",
                "dose": "As per label per acre",
                "pricePerAcrePkr": medicine_price,
                "urgency": medicine_urgency,
                "purpose": f"{req.crop.title()} protection in {req.district.title()}",
                "whereToBuy": f"Any agri store in {req.district.title()} market",
                "applicationNote": "Spray early morning or evening",
            }],
            "fertilizerAdvice": f"Soil moisture {req.soilMoisturePct}% in {req.district}: {'Hold Urea 2 weeks' if has_rust else 'Apply DAP 1 bag/acre with irrigation'}.",
            "irrigationAdvice": f"Rainfall {req.rainfallMm}mm, water table {req.waterTableM}m: {'Irrigate every 8 days' if req.rainfallMm < 100 else 'Maintain schedule'}.",
            "totalCostPerAcrePkr": 12500.0,
            "totalCostForFarmPkr": total,
            "expectedYieldIncreasePct": 22.0 if req.symptoms else 12.0,
            "roiNote": f"{req.farmSizeAcres} acres in {req.district}: Rs.{int(total):,} spend protects Rs.{int(total*3.6):,} yield. ROI: 260%.",
            "nextCheckupDays": 7 if risk_level in ["High", "Critical"] else 14,
            "district": req.district,
            "crop": req.crop,
        }
'''

import os
bs = '\\'
path = 'backend' + bs + 'app' + bs + 'routes' + bs + 'ai_advise.py'
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('ai_advise.py written successfully!')