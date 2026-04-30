import os
import httpx
from dotenv import load_dotenv

load_dotenv()

GROK_API_KEY = os.getenv('GROK_API_KEY', '')
GROK_URL = 'https://api.x.ai/v1/chat/completions'

async def get_grok_advice(req) -> dict:
    if not GROK_API_KEY or GROK_API_KEY == 'your_grok_key_here':
        raise ValueError('No Grok API key configured')

    symptoms_text = ', '.join(req.symptoms) if req.symptoms else 'none'

    prompt = f"""You are an expert agricultural advisor for Pakistan.
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
Keep Roman Urdu simple and practical for a farmer."""

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
        json_match = re.search(r'\{.*\}', content, re.DOTALL)
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
