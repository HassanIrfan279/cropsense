from __future__ import annotations

import json
from collections import defaultdict
from datetime import date, datetime, timedelta
from typing import Any

from sqlalchemy.orm import Session

from app.models.orm_models import (
    ActivityLog,
    FarmerField,
    FertilizerLog,
    FieldReport,
    FinanceLog,
    IrrigationLog,
    MedicineLog,
    User,
)
from app.services.farm_chatbot import GrokChatError, call_grok


def field_to_dict(field: FarmerField) -> dict[str, Any]:
    return {
        'id': field.id,
        'fieldName': field.field_name,
        'location': field.location,
        'areaSizeAcres': field.area_size_acres,
        'soilType': field.soil_type,
        'crop': field.crop,
        'sowingDate': field.sowing_date.isoformat() if field.sowing_date else None,
        'expectedHarvestDate': (
            field.expected_harvest_date.isoformat() if field.expected_harvest_date else None
        ),
        'waterAvailability': field.water_availability,
        'cropImageUrl': field.crop_image_url,
        'notes': field.notes,
        'createdAt': field.created_at.isoformat() if field.created_at else None,
        'updatedAt': field.updated_at.isoformat() if field.updated_at else None,
    }


def _iso(value: Any) -> str | None:
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    return None


def _sum(values: list[float]) -> float:
    return round(float(sum(values)), 2)


def _month_key(value: date) -> str:
    return f'{value.year}-{value.month:02d}'


def _risk_level(score: float) -> str:
    if score >= 70:
        return 'high'
    if score >= 38:
        return 'medium'
    return 'low'


def _timeline_item(kind: str, value: Any, title: str, amount: float = 0.0) -> dict[str, Any]:
    return {
        'id': value.id,
        'type': kind,
        'date': _iso(value.log_date),
        'title': title,
        'amountPkr': round(float(amount or 0.0), 2),
        'notes': getattr(value, 'notes', None) or getattr(value, 'safety_notes', None),
    }


def _logs(db: Session, user: User, field_id: str) -> dict[str, list[Any]]:
    return {
        'irrigation': db.query(IrrigationLog)
        .filter(IrrigationLog.user_id == user.id, IrrigationLog.field_id == field_id)
        .order_by(IrrigationLog.log_date.desc())
        .all(),
        'fertilizer': db.query(FertilizerLog)
        .filter(FertilizerLog.user_id == user.id, FertilizerLog.field_id == field_id)
        .order_by(FertilizerLog.log_date.desc())
        .all(),
        'medicine': db.query(MedicineLog)
        .filter(MedicineLog.user_id == user.id, MedicineLog.field_id == field_id)
        .order_by(MedicineLog.log_date.desc())
        .all(),
        'activity': db.query(ActivityLog)
        .filter(ActivityLog.user_id == user.id, ActivityLog.field_id == field_id)
        .order_by(ActivityLog.log_date.desc())
        .all(),
        'finance': db.query(FinanceLog)
        .filter(FinanceLog.user_id == user.id, FinanceLog.field_id == field_id)
        .order_by(FinanceLog.log_date.desc())
        .all(),
    }


def compute_field_analytics(db: Session, user: User, field: FarmerField) -> dict[str, Any]:
    logs = _logs(db, user, field.id)
    area = max(float(field.area_size_acres or 1.0), 0.01)
    category_spend: dict[str, float] = defaultdict(float)
    monthly: dict[str, dict[str, float]] = defaultdict(lambda: {'income': 0.0, 'expense': 0.0})

    irrigation_cost = _sum([float(row.cost or 0.0) for row in logs['irrigation']])
    fertilizer_cost = _sum([float(row.cost or 0.0) for row in logs['fertilizer']])
    medicine_cost = _sum([float(row.cost or 0.0) for row in logs['medicine']])
    activity_cost = _sum([float(row.cost or 0.0) for row in logs['activity']])
    activity_income = _sum([float(row.income or 0.0) for row in logs['activity']])

    category_spend['Irrigation'] += irrigation_cost
    category_spend['Fertilizer'] += fertilizer_cost
    category_spend['Medicine'] += medicine_cost
    category_spend['Activities'] += activity_cost

    for row in logs['irrigation']:
        monthly[_month_key(row.log_date)]['expense'] += float(row.cost or 0.0)
    for row in logs['fertilizer']:
        monthly[_month_key(row.log_date)]['expense'] += float(row.cost or 0.0)
    for row in logs['medicine']:
        monthly[_month_key(row.log_date)]['expense'] += float(row.cost or 0.0)
    for row in logs['activity']:
        key = _month_key(row.log_date)
        monthly[key]['expense'] += float(row.cost or 0.0)
        monthly[key]['income'] += float(row.income or 0.0)

    finance_income = 0.0
    finance_expense = 0.0
    for row in logs['finance']:
        key = _month_key(row.log_date)
        amount = float(row.amount or 0.0)
        if row.entry_type == 'income':
            finance_income += amount
            monthly[key]['income'] += amount
        else:
            finance_expense += amount
            monthly[key]['expense'] += amount
            category_spend[row.category or 'Other'] += amount

    total_spent = irrigation_cost + fertilizer_cost + medicine_cost + activity_cost + finance_expense
    total_income = activity_income + finance_income
    net_profit = total_income - total_spent
    water_usage = _sum([float(row.water_amount or 0.0) for row in logs['irrigation']])
    fertilizer_usage = _sum([float(row.quantity or 0.0) for row in logs['fertilizer']])
    medicine_usage = _sum([float(row.quantity or 0.0) for row in logs['medicine']])
    cost_per_acre = total_spent / area

    timeline = []
    for row in logs['irrigation']:
        timeline.append(_timeline_item('irrigation', row, f'Irrigation - {row.method}', row.cost))
    for row in logs['fertilizer']:
        timeline.append(_timeline_item('fertilizer', row, row.fertilizer_name, row.cost))
    for row in logs['medicine']:
        timeline.append(_timeline_item('medicine', row, row.medicine_name, row.cost))
    for row in logs['activity']:
        timeline.append(_timeline_item('activity', row, row.activity_type, row.cost or row.income))
    for row in logs['finance']:
        timeline.append(_timeline_item(row.entry_type, row, row.category, row.amount))
    timeline.sort(key=lambda item: item.get('date') or '', reverse=True)

    days_to_harvest = None
    if field.expected_harvest_date:
        days_to_harvest = (field.expected_harvest_date - date.today()).days

    upcoming = []
    last_irrigation = logs['irrigation'][0].log_date if logs['irrigation'] else None
    if last_irrigation is None or (date.today() - last_irrigation).days >= 7:
        upcoming.append('Check soil moisture and plan irrigation if the crop is under stress.')
    if days_to_harvest is not None and 0 <= days_to_harvest <= 30:
        upcoming.append('Prepare harvest labor, transport, and storage plan.')
    if not logs['fertilizer']:
        upcoming.append('Add soil-test-based fertilizer plan for this field.')
    if not upcoming:
        upcoming.append('Continue weekly scouting and update logs after each activity.')

    cost_pressure = min(40.0, (cost_per_acre / 120_000.0) * 35.0)
    medicine_pressure = min(20.0, len(logs['medicine']) * 4.0)
    water_pressure = 18.0 if field.water_availability == 'low' else 8.0
    profit_pressure = 18.0 if net_profit < 0 else 0.0
    risk_score = min(100.0, cost_pressure + medicine_pressure + water_pressure + profit_pressure)

    return {
        'field': field_to_dict(field),
        'totalCostPkr': round(total_spent, 2),
        'totalIncomePkr': round(total_income, 2),
        'netProfitPkr': round(net_profit, 2),
        'costPerAcrePkr': round(cost_per_acre, 2),
        'expectedProfitPkr': round(net_profit, 2),
        'waterUsage': round(water_usage, 2),
        'fertilizerUsage': round(fertilizer_usage, 2),
        'medicineUsage': round(medicine_usage, 2),
        'riskScore': round(risk_score, 2),
        'riskLevel': _risk_level(risk_score),
        'categoryBreakdown': [
            {'category': key, 'amount': round(value, 2)}
            for key, value in sorted(category_spend.items(), key=lambda item: item[1], reverse=True)
            if value > 0
        ],
        'monthlyMoneyFlow': [
            {
                'month': key,
                'income': round(value['income'], 2),
                'expense': round(value['expense'], 2),
                'net': round(value['income'] - value['expense'], 2),
            }
            for key, value in sorted(monthly.items())
        ],
        'usage': {
            'water': round(water_usage, 2),
            'fertilizer': round(fertilizer_usage, 2),
            'medicine': round(medicine_usage, 2),
            'irrigationEvents': len(logs['irrigation']),
            'fertilizerEvents': len(logs['fertilizer']),
            'medicineEvents': len(logs['medicine']),
        },
        'activityTimeline': timeline[:30],
        'upcomingTasks': upcoming,
        'logs': {
            'irrigation': [_irrigation_dict(row) for row in logs['irrigation']],
            'fertilizer': [_fertilizer_dict(row) for row in logs['fertilizer']],
            'medicine': [_medicine_dict(row) for row in logs['medicine']],
            'activity': [_activity_dict(row) for row in logs['activity']],
            'finance': [_finance_dict(row) for row in logs['finance']],
        },
    }


def field_comparison(db: Session, user: User) -> list[dict[str, Any]]:
    fields = db.query(FarmerField).filter(FarmerField.user_id == user.id).all()
    return [
        {
            'fieldId': field.id,
            'fieldName': field.field_name,
            'crop': field.crop,
            'totalCostPkr': analytics['totalCostPkr'],
            'totalIncomePkr': analytics['totalIncomePkr'],
            'netProfitPkr': analytics['netProfitPkr'],
            'costPerAcrePkr': analytics['costPerAcrePkr'],
            'riskLevel': analytics['riskLevel'],
        }
        for field in fields
        for analytics in [compute_field_analytics(db, user, field)]
    ]


def local_cost_advice(analytics: dict[str, Any]) -> dict[str, Any]:
    breakdown = analytics.get('categoryBreakdown', [])
    highest = breakdown[0] if breakdown else {'category': 'No spending logged', 'amount': 0}
    total_cost = float(analytics.get('totalCostPkr') or 0.0)
    cost_per_acre = float(analytics.get('costPerAcrePkr') or 0.0)
    suggestions = []
    warnings = []

    if total_cost <= 0:
        suggestions.append('Start logging every irrigation, fertilizer, medicine, labor, and transport cost.')
        warnings.append('Exact cost-saving advice is limited because no expense logs are available yet.')
    if highest['amount'] > 0:
        suggestions.append(
            f"Review {highest['category']} first; it is currently the largest spending category."
        )
    if cost_per_acre > 80_000:
        suggestions.append('Cost per acre is high. Compare supplier prices and avoid duplicate input applications.')
    if analytics.get('fertilizerUsage', 0) > 0 and not any(
        item['category'] == 'Soil Test' for item in breakdown
    ):
        suggestions.append('Use a soil test before the next fertilizer purchase to reduce waste.')
    if analytics.get('riskLevel') == 'high':
        warnings.append('Risk level is high because costs, water pressure, or profit loss are elevated.')
    if not warnings:
        warnings.append('No critical warning from the available logs, but keep records updated weekly.')

    return {
        'source': 'local-log-analysis',
        'summary': (
            f"Total logged cost is PKR {total_cost:,.0f}. Net result is "
            f"PKR {float(analytics.get('netProfitPkr') or 0):,.0f}."
        ),
        'costSavingSuggestions': suggestions[:6],
        'warnings': warnings[:5],
        'nextBestActions': analytics.get('upcomingTasks', [])[:5],
        'confidenceLevel': 'medium' if total_cost > 0 else 'low',
    }


async def ai_cost_advice(field: FarmerField, analytics: dict[str, Any]) -> dict[str, Any]:
    local = local_cost_advice(analytics)
    context = {
        'field': analytics.get('field'),
        'totals': {
            'totalCostPkr': analytics.get('totalCostPkr'),
            'totalIncomePkr': analytics.get('totalIncomePkr'),
            'netProfitPkr': analytics.get('netProfitPkr'),
            'costPerAcrePkr': analytics.get('costPerAcrePkr'),
            'riskLevel': analytics.get('riskLevel'),
        },
        'categoryBreakdown': analytics.get('categoryBreakdown'),
        'usage': analytics.get('usage'),
        'upcomingTasks': analytics.get('upcomingTasks'),
    }
    messages = [
        {
            'role': 'system',
            'content': (
                'You are CropSense AI Cost Advisor. Use only the supplied field logs and clearly say '
                'when exact data is missing. Return valid JSON with keys summary, costSavingSuggestions, '
                'warnings, nextBestActions, confidenceLevel.'
            ),
        },
        {'role': 'user', 'content': json.dumps(context, ensure_ascii=False)},
    ]
    try:
        parsed = await call_grok(messages)
        return {
            'source': 'grok-field-log-analysis',
            'summary': parsed.get('summary') or local['summary'],
            'costSavingSuggestions': parsed.get('costSavingSuggestions') or local['costSavingSuggestions'],
            'warnings': parsed.get('warnings') or local['warnings'],
            'nextBestActions': parsed.get('nextBestActions') or local['nextBestActions'],
            'confidenceLevel': parsed.get('confidenceLevel') or local['confidenceLevel'],
        }
    except GrokChatError:
        return local


def create_report(db: Session, user: User, field: FarmerField, analytics: dict[str, Any], advice: dict[str, Any]) -> dict[str, Any]:
    report = {
        'title': f'{field.field_name} Field Management Report',
        'generatedAt': datetime.utcnow().isoformat(),
        'field': field_to_dict(field),
        'analytics': analytics,
        'aiRecommendations': advice,
        'profitLossOverview': {
            'totalCostPkr': analytics['totalCostPkr'],
            'totalIncomePkr': analytics['totalIncomePkr'],
            'netProfitPkr': analytics['netProfitPkr'],
            'costPerAcrePkr': analytics['costPerAcrePkr'],
        },
    }
    row = FieldReport(
        user_id=user.id,
        field_id=field.id,
        title=report['title'],
        report_json=json.dumps(report, default=str),
    )
    db.add(row)
    db.commit()
    report['reportId'] = row.id
    return report


def _irrigation_dict(row: IrrigationLog) -> dict[str, Any]:
    return {
        'id': row.id,
        'date': _iso(row.log_date),
        'waterAmount': row.water_amount,
        'method': row.method,
        'cost': row.cost,
        'notes': row.notes,
    }


def _fertilizer_dict(row: FertilizerLog) -> dict[str, Any]:
    return {
        'id': row.id,
        'date': _iso(row.log_date),
        'fertilizerName': row.fertilizer_name,
        'fertilizerType': row.fertilizer_type,
        'quantity': row.quantity,
        'cost': row.cost,
        'purpose': row.purpose,
        'notes': row.notes,
    }


def _medicine_dict(row: MedicineLog) -> dict[str, Any]:
    return {
        'id': row.id,
        'date': _iso(row.log_date),
        'medicineName': row.medicine_name,
        'target': row.target,
        'quantity': row.quantity,
        'cost': row.cost,
        'safetyNotes': row.safety_notes,
    }


def _activity_dict(row: ActivityLog) -> dict[str, Any]:
    return {
        'id': row.id,
        'date': _iso(row.log_date),
        'activityType': row.activity_type,
        'description': row.description,
        'cost': row.cost,
        'income': row.income,
        'notes': row.notes,
    }


def _finance_dict(row: FinanceLog) -> dict[str, Any]:
    return {
        'id': row.id,
        'date': _iso(row.log_date),
        'entryType': row.entry_type,
        'category': row.category,
        'amount': row.amount,
        'description': row.description,
        'notes': row.notes,
    }
