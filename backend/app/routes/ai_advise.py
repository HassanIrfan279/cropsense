import os
import re
import json
import httpx
from fastapi import APIRouter
from pydantic import BaseModel, Field
from typing import Any, Dict, List, Optional
from app.services.grok import get_grok_advice
from app.services.farm_chatbot import answer_farm_chat

router = APIRouter()

_GROK_URL = 'https://api.x.ai/v1/chat/completions'

def _grok_key() -> str:
    return os.getenv('GROK_API_KEY') or os.getenv('XAI_API_KEY') or ''


def _grok_text_model() -> str:
    return os.getenv('GROK_MODEL', 'grok-4.3')


def _grok_vision_model() -> str:
    return os.getenv('GROK_VISION_MODEL', 'grok-4')


def _grok_timeout_seconds() -> float:
    try:
        return float(os.getenv('GROK_TIMEOUT_SECONDS', '35'))
    except ValueError:
        return 35.0

# ── Existing models ────────────────────────────────────────────────────────────

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

# ── New models ─────────────────────────────────────────────────────────────────

class ChatMessageIn(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessageIn]
    district: str = ''
    crop: str = ''
    context: Dict[str, Any] = Field(default_factory=dict)

class ImageAnalysisRequest(BaseModel):
    imageBase64: str
    district: str = ''
    crop: str = ''

# ── Existing endpoints ─────────────────────────────────────────────────────────

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
        advice = await get_grok_advice(req)
        return advice
    except Exception as e:
        print(f"Grok failed: {e} — using dynamic mock")
        has_rust   = "rust_patches"   in req.symptoms
        has_yellow = "leaf_yellowing" in req.symptoms
        has_pest   = "pest_damage"    in req.symptoms
        has_wilt   = "wilting"        in req.symptoms
        symptom_text = ", ".join(req.symptoms) if req.symptoms else "no visible symptoms"

        risk_level = "Low"
        if req.ndvi < 0.3:       risk_level = "Critical"
        elif req.ndvi < 0.5:     risk_level = "High"
        elif req.tempMaxC > 42:  risk_level = "High"
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
            med_name, med_type, med_ing = "Topsin-M 70 WP", "fungicide", "Thiophanate-methyl 70%"
            med_dose, med_price, med_urg = "250g per acre", 850.0, "immediate"
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
            med_name, med_type, med_ing = "Dithane M-45", "fungicide", "Mancozeb 80%"
            med_dose, med_price, med_urg = "500g per acre", 650.0, "within_week"
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
            med_name, med_type, med_ing = "Confidor (Imidacloprid)", "pesticide", "Imidacloprid 200 SL"
            med_dose, med_price, med_urg = "200ml per acre", 950.0, "immediate"
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
            med_name, med_type, med_ing = "Potassium Silicate (Anti-stress)", "growth_reg", "Potassium silicate 30%"
            med_dose, med_price, med_urg = "500ml per acre foliar spray", 750.0, "within_week"
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
            med_name, med_type, med_ing = "DAP Fertilizer", "fertilizer", "Diammonium Phosphate 18-46-0"
            med_dose, med_price, med_urg = "1 bag (50kg) per acre", 8500.0, "preventive"

        cost = med_price if med_type != "fertilizer" else 8500.0
        return {
            "alertUrdu": urdu,
            "alertEnglish": f"{req.crop.title()} in {req.district.title()}, {req.province}: {risk_level} risk. "
                            f"NDVI={req.ndvi}, Temp={req.tempMaxC}C, Rain={req.rainfallMm}mm. Symptoms: {symptom_text}.",
            "diagnosis": diagnosis,
            "confidencePct": 92.0 if req.symptoms else 75.0,
            "actionSteps": steps,
            "medicines": [{
                "name": med_name, "type": med_type, "activeIngredient": med_ing,
                "dose": med_dose, "pricePerAcrePkr": med_price, "urgency": med_urg,
                "purpose": f"{req.crop.title()} protection in {req.district.title()}",
                "whereToBuy": f"Any agri store in {req.district.title()} market",
                "applicationNote": "Spray early morning or evening. Wear protective gloves.",
            }],
            "fertilizerAdvice": f"Soil moisture {req.soilMoisturePct}% in {req.district}: "
                                f"{'Hold Urea 2 weeks' if has_rust else 'Apply DAP 1 bag/acre with irrigation'}.",
            "irrigationAdvice": f"Rainfall {req.rainfallMm}mm, water table {req.waterTableM}m: "
                                f"{'Irrigate every 8 days' if req.rainfallMm < 100 else 'Maintain current schedule'}.",
            "totalCostPerAcrePkr": cost,
            "totalCostForFarmPkr": cost * req.farmSizeAcres,
            "expectedYieldIncreasePct": 22.0 if req.symptoms else 12.0,
            "roiNote": f"{req.farmSizeAcres} acres in {req.district}: Rs.{int(cost * req.farmSizeAcres):,} spend "
                       f"protects Rs.{int(cost * req.farmSizeAcres * 3.6):,} yield. ROI: 260%.",
            "nextCheckupDays": 7 if risk_level in ["High", "Critical"] else 14,
            "district": req.district,
            "crop": req.crop,
        }

# ── Chat endpoint ──────────────────────────────────────────────────────────────

@router.post("/chat")
async def chat(req: ChatRequest):
    try:
        return await answer_farm_chat(req)
    except Exception as e:
        print(f"Chat Grok error: {e}")
        return _fallback_chat(req)


async def _grok_chat(messages, district, crop, context) -> dict:
    key = _grok_key()
    if not key or key == 'your_grok_key_here':
        raise ValueError('No Grok key')

    ctx_parts = []
    if district: ctx_parts.append(f"District: {district}")
    if crop:     ctx_parts.append(f"Crop: {crop}")
    if context:
        if 'ndvi'            in context: ctx_parts.append(f"NDVI: {context['ndvi']}")
        if 'rainfallMm'      in context: ctx_parts.append(f"Rainfall: {context['rainfallMm']}mm")
        if 'tempMaxC'        in context: ctx_parts.append(f"Temp: {context['tempMaxC']}C")
        if 'soilMoisturePct' in context: ctx_parts.append(f"Soil: {context['soilMoisturePct']}%")
        syms = context.get('symptoms', [])
        if syms: ctx_parts.append(f"Symptoms: {', '.join(syms)}")

    context_str = '. '.join(ctx_parts) if ctx_parts else 'General Pakistan farming query'

    system_prompt = (
        f"You are an expert agricultural advisor for Pakistan farmers. "
        f"Farm context: {context_str}. "
        "Give practical, field-specific advice in 2-4 sentences. "
        "Include a Roman Urdu translation. "
        "Respond with ONLY valid JSON — no markdown: "
        '{"reply": "English response", "replyUrdu": "Roman Urdu translation", '
        '"suggestions": ["follow-up 1", "follow-up 2", "follow-up 3"]}'
    )

    grok_msgs = [{"role": "system", "content": system_prompt}]
    for m in messages[-10:]:
        grok_msgs.append({"role": m.role, "content": m.content})

    async with httpx.AsyncClient(timeout=_grok_timeout_seconds()) as client:
        resp = await client.post(
            _GROK_URL,
            headers={'Authorization': f'Bearer {key}', 'Content-Type': 'application/json'},
            json={'model': _grok_text_model(), 'messages': grok_msgs, 'temperature': 0.7, 'max_tokens': 600},
        )
        if resp.status_code != 200:
            raise ValueError(f"Grok returned {resp.status_code}: {resp.text[:200]}")
        content = resp.json()['choices'][0]['message']['content'].strip()
        content = re.sub(r'^```json\s*|\s*```$', '', content, flags=re.MULTILINE).strip()
        m = re.search(r'\{.*\}', content, re.DOTALL)
        return json.loads(m.group() if m else content)


def _fallback_chat(req: ChatRequest) -> dict:
    last = req.messages[-1].content.lower() if req.messages else ""
    crop = req.crop or 'wheat'
    dist = req.district or 'your district'

    if 'disease' in last or 'rust' in last or 'yellow' in last or 'spot' in last:
        reply = (f"For {crop} disease management in {dist}: scout fields weekly, apply preventive "
                 f"fungicide (Topsin-M 250g/acre) when humid, and remove infected plant material. "
                 f"Early detection prevents 40-60% yield loss.")
        urdu  = f"{crop} ki bimari ke liye: hafta wari muaina karein, Topsin-M 250g/acre spray karein."
    elif 'water' in last or 'irrigat' in last or 'pani' in last:
        reply = (f"For {crop} in {dist}: irrigate every 8-12 days based on soil moisture, prefer "
                 f"early morning irrigation to reduce evaporation. Check for waterlogging — standing "
                 f"water for >24 hrs causes root damage.")
        urdu  = f"{crop} ki aabpashi: 8-12 din baad pani dein, subah ka waqt behtar hai."
    elif 'fertiliz' in last or 'urea' in last or 'dap' in last or 'khaad' in last:
        reply = (f"For {crop} in {dist}: apply DAP at sowing (1 bag/acre), split Urea in 2 doses — "
                 f"at tillering and heading. Always apply after irrigation for best absorption.")
        urdu  = f"{crop} ke liye: biji par DAP 1 bori, Urea do martaba dein — koney aur bali par."
    elif 'heat' in last or 'temp' in last or 'garmi' in last:
        reply = (f"Heat stress management for {crop} in {dist}: irrigate in the evening, apply "
                 f"anti-stress foliar spray (potassium silicate 500ml/acre), avoid fertilizer "
                 f"during peak heat (>42°C). Mulching cuts soil temperature by 5-8°C.")
        urdu  = f"Garmi se bachao: shaam ko pani dein, potassium silicate spray karein, mulch lagaein."
    elif 'pest' in last or 'keera' in last or 'insect' in last:
        reply = (f"Pest control for {crop} in {dist}: use IPM — scout twice weekly, spray Confidor "
                 f"200ml/acre only when infestation >10% ETL. Spray early morning or evening. "
                 f"Preserve natural predators like spiders and ladybirds.")
        urdu  = f"Keeray ke liye: Confidor 200ml/aci spray karein, subah ya shaam spray karein."
    else:
        reply = (f"For {crop} in {dist}: monitor weekly for stress signs (yellowing, wilting, spots). "
                 f"Maintain soil moisture 30-60%, protect against fungal diseases, and adjust "
                 f"irrigation based on rainfall. Exact yield, price, and spray choices need current local data.")
        urdu  = f"{crop} ki kheti: hafta wari monitoring, soil moisture 30-60%, phaphoond se bachein."

    return {
        "reply": reply,
        "directAnswer": reply,
        "explanation": (
            "The personalized Grok/context service could not complete, so this is a limited local fallback."
        ),
        "dataUsed": [
            f"Selected crop: {crop}",
            f"Selected district: {dist}",
            "Basic field context from the AI Analyzer form",
        ],
        "recommendation": "Use this as a quick first check, then retry the chatbot when the backend context service is available.",
        "risksWarnings": [
            "This fallback does not include full 2005-2023 analytics.",
            "Do not apply pesticides without checking the product label and local extension advice.",
            "No live market price was used.",
        ],
        "nextSteps": [
            "Check crop symptoms in the field.",
            "Confirm irrigation need from soil moisture.",
            "Retry the chatbot for a full data-backed answer.",
        ],
        "confidenceLevel": "low",
        "sourceLabels": ["Limited local fallback"],
        "status": "fallback",
        "replyUrdu": urdu,
        "suggestions": [
            f"What are early disease symptoms in {crop}?",
            f"Best fertilizer timing for {crop} this season?",
            f"How to improve NDVI for my {crop} field?",
        ],
    }

# ── Image analysis endpoint ────────────────────────────────────────────────────

@router.post("/analyze-image")
async def analyze_image(req: ImageAnalysisRequest):
    try:
        return await _grok_vision(req.imageBase64, req.district, req.crop)
    except Exception as e:
        print(f"Vision Grok error: {e}")
        return _fallback_vision(req.district, req.crop)


async def _grok_vision(image_base64: str, district: str, crop: str) -> dict:
    key = _grok_key()
    if not key or key == 'your_grok_key_here':
        raise ValueError('No Grok key')

    prompt_text = (
        f"Analyze this {crop} crop image from {district}, Pakistan. "
        "Identify any disease, pest damage, nutrient deficiency, or stress. "
        "Respond with ONLY valid JSON — no markdown: "
        '{"disease": "name or None", "severity": "Low/Moderate/High/Critical", '
        '"affectedPct": 25, "description": "what you observe", '
        '"treatment": "recommended action", '
        '"medicineName": "specific product", "medicinePrice": 850, '
        '"urgency": "immediate/within_week/preventive", '
        '"roiNote": "cost-benefit note", '
        '"urduSummary": "Roman Urdu 1-sentence summary", '
        '"suggestions": ["follow-up 1", "follow-up 2", "follow-up 3"]}'
    )

    async with httpx.AsyncClient(timeout=_grok_timeout_seconds()) as client:
        resp = await client.post(
            _GROK_URL,
            headers={'Authorization': f'Bearer {key}', 'Content-Type': 'application/json'},
            json={
                'model': _grok_vision_model(),
                'messages': [{
                    'role': 'user',
                    'content': [
                        {'type': 'image_url',
                         'image_url': {'url': f'data:image/jpeg;base64,{image_base64}'}},
                        {'type': 'text', 'text': prompt_text},
                    ],
                }],
                'temperature': 0.3,
                'max_tokens': 800,
            },
        )
        if resp.status_code != 200:
            raise ValueError(f"Grok vision returned {resp.status_code}: {resp.text[:200]}")
        content = resp.json()['choices'][0]['message']['content'].strip()
        content = re.sub(r'^```json\s*|\s*```$', '', content, flags=re.MULTILINE).strip()
        m = re.search(r'\{.*\}', content, re.DOTALL)
        return json.loads(m.group() if m else content)


def _fallback_vision(district: str, crop: str) -> dict:
    district = district or 'your district'
    crop     = crop     or 'crop'
    return {
        "disease":       "Suspected Fungal Infection",
        "severity":      "Moderate",
        "affectedPct":   30,
        "description":   (f"Analysis of {crop} image from {district}. "
                          "Visible leaf discolouration and irregular spots detected. "
                          "Manual scouting recommended to confirm diagnosis."),
        "treatment":     "Apply Dithane M-45 (500g/acre) as a protectant. Ensure field drainage. "
                         "Remove severely infected plant material and burn.",
        "medicineName":  "Dithane M-45 (Mancozeb 80%)",
        "medicinePrice": 650.0,
        "urgency":       "within_week",
        "roiNote":       f"Rs.650/acre treatment protects an estimated Rs.5,000+ yield for {crop}. ROI > 600%.",
        "urduSummary":   f"{district} mein {crop} par phaphoond ka shubha — Dithane M-45 spray karein.",
        "suggestions": [
            "How to prevent fungal disease next season?",
            "Are these symptoms spreading to neighbouring plants?",
            "What is the correct Dithane spray interval?",
        ],
    }
