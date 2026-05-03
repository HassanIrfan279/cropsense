import os
import httpx
import json
import re
from dotenv import load_dotenv

load_dotenv()

GROK_URL = 'https://api.x.ai/v1/chat/completions'


def _grok_key() -> str:
    return os.getenv('GROK_API_KEY') or os.getenv('XAI_API_KEY') or ''


def _grok_text_model() -> str:
    return os.getenv('GROK_MODEL', 'grok-4.3')


def _grok_timeout_seconds() -> float:
    try:
        return float(os.getenv('GROK_TIMEOUT_SECONDS', '35'))
    except ValueError:
        return 35.0

async def get_grok_advice(req) -> dict:
    grok_api_key = _grok_key()
    if not grok_api_key or grok_api_key == 'your_grok_key_here':
        raise ValueError('No Grok API key configured')

    symptoms_text = ', '.join(req.symptoms) if req.symptoms else 'no symptoms'

    prompt = f"""You are an expert agricultural advisor for Pakistan farmers.
A farmer in {req.district}, {req.province} needs urgent advice for their {req.crop} crop.

Current Field Conditions:
- Season: {req.season}
- Farm size: {req.farmSizeAcres} acres
- NDVI (vegetation health 0-1): {req.ndvi}
- Rainfall last 30 days: {req.rainfallMm}mm
- Maximum temperature: {req.tempMaxC}°C
- Soil moisture: {req.soilMoisturePct}%
- Water table depth: {req.waterTableM}m
- Observed symptoms: {symptoms_text}

Based on these SPECIFIC conditions, provide personalized agricultural advice.
If NDVI is low (below 0.4), focus on vegetation stress.
If temperature is high (above 40), focus on heat stress.
If rainfall is low (below 50mm), focus on drought.
If symptoms include rust_patches or leaf_yellowing, focus on disease.

Respond with ONLY a valid JSON object (no markdown, no backticks):
{{
  "alertUrdu": "Roman Urdu warning specific to their conditions (2-3 sentences)",
  "alertEnglish": "English alert specific to their conditions (2-3 sentences)",
  "diagnosis": "Specific diagnosis based on their NDVI={req.ndvi}, temp={req.tempMaxC}C, symptoms={symptoms_text}",
  "confidencePct": 85,
  "actionSteps": [
    "Step 1 specific to their conditions",
    "Step 2 with specific doses",
    "Step 3 with timing",
    "Step 4 follow-up",
    "Step 5 prevention"
  ],
  "fertilizerAdvice": "Specific fertilizer advice for {req.crop} in {req.district} given current soil moisture {req.soilMoisturePct}%",
  "irrigationAdvice": "Specific irrigation advice given rainfall {req.rainfallMm}mm and water table {req.waterTableM}m",
  "totalCostPerAcrePkr": 12500,
  "expectedYieldIncreasePct": 18,
  "roiNote": "ROI explanation specific to {req.crop} in {req.district}",
  "nextCheckupDays": 7
}}"""

    try:
        async with httpx.AsyncClient(timeout=_grok_timeout_seconds()) as client:
            response = await client.post(
                GROK_URL,
                headers={
                    'Authorization': f'Bearer {grok_api_key}',
                    'Content-Type': 'application/json',
                },
                json={
                    'model': _grok_text_model(),
                    'messages': [
                        {
                            'role': 'system',
                            'content': 'You are an agricultural AI advisor for Pakistan. Always respond with valid JSON only. Never use markdown formatting.'
                        },
                        {
                            'role': 'user',
                            'content': prompt
                        }
                    ],
                    'temperature': 0.7,
                    'max_tokens': 1500,
                },
            )

            if response.status_code != 200:
                print(f'Grok API error: {response.status_code} - {response.text}')
                raise ValueError(f'Grok API returned {response.status_code}')

            data = response.json()
            content = data['choices'][0]['message']['content']

            print(f'Grok raw response: {content[:200]}')

            # Clean the response
            content = content.strip()
            content = re.sub(r'^```json\s*', '', content)
            content = re.sub(r'^```\s*', '', content)
            content = re.sub(r'\s*```$', '', content)
            content = content.strip()

            # Find JSON object
            json_match = re.search(r'\{.*\}', content, re.DOTALL)
            if json_match:
                advice = json.loads(json_match.group())
            else:
                advice = json.loads(content)

            # Add required fields
            advice['medicines'] = []
            advice['totalCostForFarmPkr'] = (
                advice.get('totalCostPerAcrePkr', 12500) * req.farmSizeAcres
            )
            advice['district'] = req.district
            advice['crop'] = req.crop

            print(f'Grok advice generated successfully for {req.district}/{req.crop}')
            return advice

    except json.JSONDecodeError as e:
        print(f'JSON parse error: {e}')
        print(f'Content was: {content}')
        raise ValueError(f'Could not parse Grok response: {e}')
    except httpx.TimeoutException:
        print('Grok API timeout')
        raise ValueError('Grok API timed out')
    except Exception as e:
        print(f'Grok error: {type(e).__name__}: {e}')
        raise
