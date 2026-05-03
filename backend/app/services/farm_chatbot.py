from __future__ import annotations

import json
import os
import re
from typing import Any

import httpx

from app.routes.analytics import analytics_summary
from app.services.risk_map_service import build_risk_map

GROK_URL = 'https://api.x.ai/v1/chat/completions'
DEFAULT_MODEL = 'grok-4.3'


class GrokChatError(Exception):
    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code


def _api_key() -> str:
    return os.getenv('GROK_API_KEY') or os.getenv('XAI_API_KEY') or ''


def _model_name() -> str:
    return os.getenv('GROK_MODEL') or DEFAULT_MODEL


def _timeout_seconds() -> float:
    try:
        return float(os.getenv('GROK_TIMEOUT_SECONDS', '35'))
    except ValueError:
        return 35.0


def _last_user_message(messages: list[Any]) -> str:
    for message in reversed(messages):
        role = getattr(message, 'role', '') or ''
        content = getattr(message, 'content', '') or ''
        if role == 'user' and content.strip():
            return content.strip()
    return ''


def _context(req: Any) -> dict[str, Any]:
    raw = getattr(req, 'context', None) or {}
    return raw if isinstance(raw, dict) else {}


def _float_value(value: Any, fallback: float) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return fallback


def _int_value(value: Any, fallback: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return fallback


def _list_strings(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if str(item).strip()]


def _safe_get(data: dict[str, Any], path: list[str], fallback: Any = None) -> Any:
    current: Any = data
    for key in path:
        if not isinstance(current, dict) or key not in current:
            return fallback
        current = current[key]
    return current


def _crop_label(crop: str) -> str:
    return crop.replace('-', ' ').title() if crop else 'Selected crop'


def _pct(value: Any) -> str:
    try:
        return f"{float(value) * 100:.0f}%"
    except (TypeError, ValueError):
        return 'unknown'


def _money(value: Any) -> str:
    try:
        return f"PKR {float(value):,.0f}"
    except (TypeError, ValueError):
        return 'unknown'


def _build_filters(req: Any) -> dict[str, Any]:
    ctx = _context(req)
    return {
        'district': (getattr(req, 'district', '') or ctx.get('district') or 'faisalabad').lower(),
        'crop': (getattr(req, 'crop', '') or ctx.get('crop') or 'wheat').lower(),
        'province': ctx.get('province') or '',
        'season': ctx.get('season') or 'all',
        'soilType': ctx.get('soilType') or 'loam',
        'farmAcres': _float_value(ctx.get('farmSizeAcres'), 5.0),
        'budgetPkr': _float_value(ctx.get('budgetPkr'), 0.0),
        'startYear': _int_value(ctx.get('startYear'), 2005),
        'endYear': _int_value(ctx.get('endYear'), 2023),
        'selectedYear': _int_value(ctx.get('selectedYear') or ctx.get('year'), _int_value(ctx.get('endYear'), 2023)),
        'ndvi': _float_value(ctx.get('ndvi'), 0.0),
        'rainfallMm': _float_value(ctx.get('rainfallMm'), 0.0),
        'tempMaxC': _float_value(ctx.get('tempMaxC'), 0.0),
        'soilMoisturePct': _float_value(ctx.get('soilMoisturePct'), 0.0),
        'waterTableM': _float_value(ctx.get('waterTableM'), 0.0),
        'symptoms': _list_strings(ctx.get('symptoms')),
    }


def _compact_rows(rows: list[dict[str, Any]], limit: int = 5) -> list[dict[str, Any]]:
    compact = []
    for row in rows[-limit:]:
        compact.append({
            'year': row.get('year'),
            'yieldTAcre': row.get('yieldTAcre'),
            'profitPerAcre': row.get('profitPerAcre'),
            'rainfallMm': row.get('rainfallMm'),
            'tempMaxC': row.get('tempMaxC'),
            'weatherRiskType': row.get('weatherRiskType'),
        })
    return compact


def _compact_test(name: str, result: Any) -> dict[str, Any]:
    if not isinstance(result, dict):
        return {'name': name, 'available': False, 'message': 'Not available.'}
    return {
        'name': name,
        'available': result.get('available', False),
        'pValue': result.get('pValue'),
        'significant': result.get('significant'),
        'plainEnglish': result.get('plainEnglish') or result.get('message'),
    }


def _selected_crop_metrics(
    selected_response: dict[str, Any],
    comparison_response: dict[str, Any],
    crop: str,
) -> dict[str, Any]:
    crops = comparison_response.get('crops') or {}
    if crop in crops:
        return crops[crop]
    return selected_response.get('selectedCrop') or comparison_response.get('selectedCrop') or {}


def _compact_analytics(
    comparison_response: dict[str, Any],
    selected_response: dict[str, Any],
    filters: dict[str, Any],
) -> dict[str, Any]:
    selected = _selected_crop_metrics(selected_response, comparison_response, filters['crop'])
    selected_rows = selected.get('yearly') or _safe_get(selected_response, ['yieldTrend', 'yearly'], [])
    crop_rows = _safe_get(comparison_response, ['cropPerformance', 'rows'], [])
    testing = selected_response.get('statisticalTesting') or comparison_response.get('statisticalTesting') or {}

    return {
        'source': comparison_response.get('dataSource', 'Project analytics data'),
        'isDemoData': bool(comparison_response.get('isDemoData', False)),
        'dataQuality': comparison_response.get('dataQuality', {}),
        'yearRange': comparison_response.get('yearRange') or f"{filters['startYear']}-{filters['endYear']}",
        'topSummary': comparison_response.get('summary', {}),
        'cropComparison': [
            {
                'crop': row.get('crop'),
                'meanYield': row.get('meanYield'),
                'expectedProfitPerAcre': row.get('expectedProfitPerAcre'),
                'probabilityLoss': row.get('probabilityLoss'),
                'riskLevel': row.get('riskLevel'),
                'roiPct': row.get('roiPct'),
            }
            for row in crop_rows[:6]
        ],
        'selectedCrop': {
            'crop': filters['crop'],
            'label': _crop_label(filters['crop']),
            'descriptiveStats': selected.get('descriptiveStats', {}),
            'expectedProfitPerAcre': selected.get('expectedProfitPerAcre'),
            'riskLevel': selected.get('riskLevel'),
            'riskScore': selected.get('riskScore'),
            'probabilities': selected.get('probabilities', {}),
            'thresholds': selected.get('thresholds', {}),
            'yieldConfidenceInterval': selected.get('yieldConfidenceInterval', {}),
            'profitConfidenceInterval': selected.get('profitConfidenceInterval', {}),
            'regression': selected.get('regression', {}),
            'multiFactorRegression': selected.get('multiFactorRegression', {}),
            'correlations': selected.get('correlations', {}),
            'recentYearlyRows': _compact_rows(selected_rows),
        },
        'statisticalTests': [
            _compact_test('t-test yield', testing.get('tTestYield')),
            _compact_test('t-test profit', testing.get('tTestProfit')),
            _compact_test('ANOVA yield', testing.get('anovaYield')),
            _compact_test('ANOVA profit', testing.get('anovaProfit')),
            _compact_test('chi-square weather risk', testing.get('chiSquareWeatherRisk')),
        ],
        'analyticsInsight': selected_response.get('aiInsights') or comparison_response.get('aiInsights') or {},
    }


async def build_farm_context(req: Any) -> dict[str, Any]:
    filters = _build_filters(req)
    comparison = await analytics_summary(
        filters['district'],
        farm_acres=filters['farmAcres'],
        crop='all',
        season=filters['season'],
        start_year=filters['startYear'],
        end_year=filters['endYear'],
        soil_type=filters['soilType'],
    )
    selected = await analytics_summary(
        filters['district'],
        farm_acres=filters['farmAcres'],
        crop=filters['crop'],
        season=filters['season'],
        start_year=filters['startYear'],
        end_year=filters['endYear'],
        soil_type=filters['soilType'],
    )
    risk_map = build_risk_map(filters['crop'], filters['selectedYear'])
    risk_entry = next(
        (
            row for row in risk_map.get('districts', [])
            if row.get('district') == filters['district']
        ),
        None,
    )
    raw_context = _context(req)
    return {
        'farmerProfile': filters,
        'analytics': _compact_analytics(comparison, selected, filters),
        'riskMap': {
            'selectedCrop': filters['crop'],
            'selectedYear': filters['selectedYear'],
            'districtRisk': risk_entry or {},
            'dataSource': risk_map.get('dataSource'),
            'yearRange': risk_map.get('yearRange'),
        },
        'fieldData': raw_context.get('fieldData') or {},
        'sourceLabels': [
            f"CropSense analytics {filters['startYear']}-{filters['endYear']}",
            f"Risk map {filters['selectedYear']} for {filters['crop']}",
            'Farmer profile from AI Analyzer',
            'Weather/yield/cost/profit/risk summaries',
        ],
        'uncertaintyRules': [
            'Do not invent exact real-time market prices or pesticide labels.',
            'If data is demo, historical, missing, or uncertain, say that clearly.',
            'For pesticide or disease treatment, recommend local extension confirmation and label directions.',
        ],
    }


def build_prompt_messages(req: Any, farm_context: dict[str, Any]) -> list[dict[str, str]]:
    messages = getattr(req, 'messages', []) or []
    question = _last_user_message(messages)
    history = [
        {'role': getattr(message, 'role', 'user'), 'content': getattr(message, 'content', '')}
        for message in messages[-8:]
        if getattr(message, 'content', '').strip()
    ]
    system = (
        'You are the CropSense personalized farming assistant for Pakistan farmers. '
        'Use the structured project context first, then general agronomy knowledge only when project data is missing. '
        'Never blindly guess. Never claim live market/weather certainty unless supplied in context. '
        'Use simple English, practical field language, and academically correct interpretation of statistics. '
        'Return ONLY valid JSON with these keys: '
        'directAnswer, explanation, dataUsed, recommendation, risksWarnings, nextSteps, confidenceLevel, suggestions. '
        'dataUsed, risksWarnings, nextSteps, and suggestions must be arrays of short strings. '
        'confidenceLevel must be high, medium, or low.'
    )
    user = {
        'question': question,
        'conversationHistory': history,
        'farmContext': farm_context,
        'requiredResponseOrder': [
            'Direct answer first',
            'Short explanation',
            'Data used',
            'Recommendation',
            'Risks/warnings',
            'Next steps',
            'Confidence level',
        ],
    }
    return [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': json.dumps(user, ensure_ascii=False)},
    ]


def _extract_json_object(content: str) -> dict[str, Any]:
    cleaned = content.strip()
    cleaned = re.sub(r'^```json\s*', '', cleaned, flags=re.IGNORECASE)
    cleaned = re.sub(r'^```\s*', '', cleaned)
    cleaned = re.sub(r'\s*```$', '', cleaned)
    match = re.search(r'\{.*\}', cleaned, re.DOTALL)
    raw_json = match.group() if match else cleaned
    parsed = json.loads(raw_json)
    if not isinstance(parsed, dict):
        raise ValueError('Grok response JSON was not an object')
    return parsed


def _as_string_list(value: Any) -> list[str]:
    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]
    if isinstance(value, str) and value.strip():
        return [value.strip()]
    return []


def _normalize_response(
    parsed: dict[str, Any],
    farm_context: dict[str, Any],
    *,
    status: str,
    warning: str = '',
) -> dict[str, Any]:
    confidence = str(parsed.get('confidenceLevel') or 'medium').lower()
    if confidence not in {'high', 'medium', 'low'}:
        confidence = 'medium'

    direct = str(parsed.get('directAnswer') or parsed.get('reply') or '').strip()
    explanation = str(parsed.get('explanation') or '').strip()
    recommendation = str(parsed.get('recommendation') or '').strip()
    data_used = _as_string_list(parsed.get('dataUsed'))
    risks = _as_string_list(parsed.get('risksWarnings'))
    next_steps = _as_string_list(parsed.get('nextSteps'))
    suggestions = _as_string_list(parsed.get('suggestions'))

    if not data_used:
        data_used = ['CropSense analytics and farmer profile context']
    if not suggestions:
        profile = farm_context.get('farmerProfile', {})
        crop = _crop_label(str(profile.get('crop') or 'crop'))
        suggestions = [
            f'How can I reduce risk for {crop}?',
            'Explain my analytics report',
            'Generate my crop plan',
        ]

    reply = _format_reply(direct, explanation, data_used, recommendation, risks, next_steps, confidence)
    source_labels = list(farm_context.get('sourceLabels', []))
    if bool(_safe_get(farm_context, ['analytics', 'isDemoData'], False)):
        source_labels.append('Demo data clearly marked')

    return {
        'reply': reply,
        'directAnswer': direct or 'I do not have enough information for an exact answer.',
        'explanation': explanation,
        'dataUsed': data_used,
        'recommendation': recommendation,
        'risksWarnings': risks,
        'nextSteps': next_steps,
        'confidenceLevel': confidence,
        'suggestions': suggestions[:5],
        'sourceLabels': source_labels,
        'status': status,
        'warning': warning,
        'model': _model_name() if status == 'grok' else 'local-data-fallback',
    }


def _format_reply(
    direct: str,
    explanation: str,
    data_used: list[str],
    recommendation: str,
    risks: list[str],
    next_steps: list[str],
    confidence: str,
) -> str:
    lines = [direct or 'I do not have enough information for an exact answer.']
    if explanation:
        lines.extend(['', f'Why: {explanation}'])
    if data_used:
        lines.extend(['', 'Data used:'])
        lines.extend([f'- {item}' for item in data_used])
    if recommendation:
        lines.extend(['', f'Recommendation: {recommendation}'])
    if risks:
        lines.extend(['', 'Risks/warnings:'])
        lines.extend([f'- {item}' for item in risks])
    if next_steps:
        lines.extend(['', 'Next steps:'])
        lines.extend([f'{idx}. {item}' for idx, item in enumerate(next_steps, start=1)])
    lines.extend(['', f'Confidence: {confidence}'])
    return '\n'.join(lines)


async def call_grok(messages: list[dict[str, str]]) -> dict[str, Any]:
    key = _api_key()
    if not key or key == 'your_grok_key_here':
        raise GrokChatError('missing_api_key', 'No Grok API key is configured.')

    try:
        async with httpx.AsyncClient(timeout=_timeout_seconds()) as client:
            response = await client.post(
                GROK_URL,
                headers={
                    'Authorization': f'Bearer {key}',
                    'Content-Type': 'application/json',
                },
                json={
                    'model': _model_name(),
                    'messages': messages,
                    'temperature': 0.35,
                    'max_tokens': 1200,
                    'stream': False,
                },
            )
    except httpx.TimeoutException as exc:
        raise GrokChatError('timeout', 'Grok API request timed out.') from exc
    except httpx.HTTPError as exc:
        raise GrokChatError('network_error', f'Could not reach Grok API: {exc}') from exc

    if response.status_code in {401, 403}:
        raise GrokChatError('invalid_key', 'Grok API rejected the configured key.')
    if response.status_code >= 400:
        raise GrokChatError('api_error', f'Grok API returned HTTP {response.status_code}.')

    try:
        data = response.json()
        content = data['choices'][0]['message']['content']
    except (KeyError, IndexError, TypeError, json.JSONDecodeError) as exc:
        raise GrokChatError('empty_response', 'Grok API returned an empty or invalid response.') from exc

    if not str(content).strip():
        raise GrokChatError('empty_response', 'Grok API returned an empty response.')

    try:
        return _extract_json_object(str(content))
    except (json.JSONDecodeError, ValueError) as exc:
        raise GrokChatError('invalid_json', 'Grok response was not valid structured JSON.') from exc


def _fallback_response(req: Any, farm_context: dict[str, Any], error: GrokChatError) -> dict[str, Any]:
    profile = farm_context.get('farmerProfile', {})
    analytics = farm_context.get('analytics', {})
    selected = analytics.get('selectedCrop', {})
    summary = analytics.get('topSummary', {})
    probabilities = selected.get('probabilities', {})
    stats = selected.get('descriptiveStats', {})
    risk_entry = _safe_get(farm_context, ['riskMap', 'districtRisk'], {}) or {}
    field_data = farm_context.get('fieldData') or {}
    question = _last_user_message(getattr(req, 'messages', []) or []).lower()

    crop = str(profile.get('crop') or 'crop')
    district = str(profile.get('district') or 'your district').replace('-', ' ').title()
    expected_profit = selected.get('expectedProfitPerAcre') or summary.get('expectedProfitPerAcre')
    mean_yield = stats.get('mean') or summary.get('averageYield')
    loss_probability = probabilities.get('loss') or summary.get('probabilityOfLoss')
    best_crop = summary.get('mostProfitableCrop') or summary.get('bestPerformingCrop')
    year = profile.get('selectedYear') or profile.get('endYear') or 2023
    risk_level = risk_entry.get('riskLevel') or selected.get('riskLevel') or 'unknown'
    risk_score = risk_entry.get('riskScore') or selected.get('riskScore')
    weather_risks = _as_string_list(risk_entry.get('weatherRisks'))
    crop_risks = _as_string_list(risk_entry.get('cropRisks'))

    data_used = [
        f"Historical analytics {analytics.get('yearRange', '2005-2023')}",
        f"Risk map {year} for {_crop_label(crop)} in {district}",
        f"Farm size {profile.get('farmAcres')} acres, soil {profile.get('soilType')}, season {profile.get('season')}",
    ]
    if field_data:
        data_used.append('Logged field-management records supplied by the frontend')
    if not risk_entry:
        data_used.append('Risk-map district record was unavailable')

    risks = [
        'This fallback does not use live market prices.',
        'Chemical recommendations must be checked against the product label and local extension advice.',
    ]
    risks.extend(weather_risks[:2])
    risks.extend(crop_risks[:2])

    next_steps = [
        'Confirm crop stage and field symptoms.',
        'Check soil moisture before irrigation or fertilizer.',
        'Retry after configuring Grok for a full natural-language answer.',
    ]

    if any(term in question for term in ['best crop', 'which crop', 'select crop', 'crop selection']):
        direct = (
            f'Based on the available CropSense analytics, compare {_crop_label(str(best_crop or crop))} first for {district}. '
            f'{_crop_label(crop)} is currently {risk_level} risk for {year}.'
        )
        recommendation = (
            f'Use {_crop_label(str(best_crop or crop))} as the main option if your soil, water, and budget match it; '
            f'keep {_crop_label(crop)} only if you can manage the listed risks.'
        )
    elif any(term in question for term in ['profit', 'cost', 'income', 'loss', 'budget']):
        direct = (
            f'Expected profit for {_crop_label(crop)} is about {_money(expected_profit)} per acre from the available analytics; '
            f'loss probability is around {_pct(loss_probability)}.'
        )
        recommendation = (
            'Do not spend the full budget at sowing. Keep cash for irrigation, pest control, and emergency fertilizer.'
        )
        if field_data:
            recommendation += ' Your field logs should be used to compare planned cost against actual spending.'
    elif any(term in question for term in ['fertilizer', 'urea', 'dap', 'npk', 'khaad']):
        direct = (
            f'I do not have a lab soil-test result, so I cannot give an exact fertilizer dose for {_crop_label(crop)}. '
            'Use the analytics and soil moisture as planning context, then confirm with a soil test.'
        )
        recommendation = (
            'Apply fertilizer in split doses and avoid heavy nitrogen when disease pressure or water stress is high.'
        )
        risks.append('Exact fertilizer dose is uncertain because soil nutrient data is missing.')
    elif any(term in question for term in ['disease', 'pest', 'medicine', 'spray', 'fungicide', 'insect']):
        symptoms = _as_string_list(profile.get('symptoms'))
        direct = (
            f'For {_crop_label(crop)} in {district}, disease/pest advice is limited without confirmed scouting. '
            f'Current selected symptoms: {", ".join(symptoms) if symptoms else "none provided"}.'
        )
        recommendation = (
            'Scout affected plants first, identify the pest or disease, then choose medicine by label directions and local advice.'
        )
        risks.append('Do not spray blindly; wrong pesticide can waste money and harm beneficial insects.')
    elif any(term in question for term in ['risk', 'weather', 'rain', 'heat', 'drought', 'flood']):
        direct = (
            f'{_crop_label(crop)} in {district} is {risk_level} risk for {year}'
            f'{f" with score {float(risk_score):.0f}/100" if risk_score is not None else ""}.'
        )
        recommendation = (
            'Use irrigation buffers, drainage checks, and weekly scouting during risky weather windows.'
        )
    elif any(term in question for term in ['analytics', 'statistics', 'p-value', 'regression', 'confidence']):
        direct = (
            f'The analytics for {_crop_label(crop)} show mean yield near {mean_yield or "unknown"} t/acre, '
            f'expected profit near {_money(expected_profit)}, and {risk_level} risk.'
        )
        recommendation = (
            'Treat statistically significant results as stronger evidence, but keep uncertainty in mind for farm decisions.'
        )
    elif any(term in question for term in ['plan', 'calendar', 'steps', 'future']):
        direct = (
            f'For {_crop_label(crop)} in {district}, plan around the {year} risk level ({risk_level}) and your available budget.'
        )
        recommendation = (
            'Make a staged crop plan: land preparation, sowing, irrigation, fertilizer splits, scouting, and harvest cost tracking.'
        )
        next_steps = [
            'Set sowing and expected harvest dates.',
            'Create irrigation and fertilizer reminders.',
            'Track every expense in Field Management.',
            'Review profit and risk weekly.',
        ]
    else:
        direct = (
            f'For {_crop_label(crop)} in {district}, the available project data shows {risk_level} risk, '
            f'mean yield near {mean_yield or "unknown"} t/acre, and expected profit near {_money(expected_profit)}.'
        )
        recommendation = (
            'Ask a more specific question about crop choice, profit, fertilizer, weather, pests, or planning for a sharper answer.'
        )

    explanation = (
        f'Grok is unavailable ({error.code}), so this answer uses CropSense backend data only. '
        f'It combines analytics, selected farmer filters, risk-map data, and any field logs sent by the app. '
        'Missing exact data is called out instead of guessed.'
    )
    confidence = 'medium' if mean_yield and expected_profit is not None else 'low'
    return _normalize_response(
        {
            'directAnswer': direct,
            'explanation': explanation,
            'dataUsed': data_used,
            'recommendation': recommendation,
            'risksWarnings': risks,
            'nextSteps': next_steps,
            'confidenceLevel': confidence,
            'suggestions': [
                'Which crop is best for me?',
                'How much profit can I expect?',
                'Generate my crop plan',
            ],
        },
        farm_context,
        status='fallback',
        warning=error.args[0] if error.args else error.code,
    )


async def answer_farm_chat(req: Any) -> dict[str, Any]:
    farm_context = await build_farm_context(req)
    prompt_messages = build_prompt_messages(req, farm_context)
    try:
        parsed = await call_grok(prompt_messages)
        return _normalize_response(parsed, farm_context, status='grok')
    except GrokChatError as error:
        return _fallback_response(req, farm_context, error)
