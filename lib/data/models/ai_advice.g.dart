// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_advice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIAdviceImpl _$$AIAdviceImplFromJson(Map<String, dynamic> json) =>
    _$AIAdviceImpl(
      alertUrdu: json['alertUrdu'] as String,
      alertEnglish: json['alertEnglish'] as String,
      diagnosis: json['diagnosis'] as String,
      confidencePct: (json['confidencePct'] as num).toDouble(),
      actionSteps: (json['actionSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medicines: (json['medicines'] as List<dynamic>)
          .map((e) => Medicine.fromJson(e as Map<String, dynamic>))
          .toList(),
      fertilizerAdvice: json['fertilizerAdvice'] as String,
      irrigationAdvice: json['irrigationAdvice'] as String,
      totalCostPerAcrePkr: (json['totalCostPerAcrePkr'] as num).toDouble(),
      totalCostForFarmPkr: (json['totalCostForFarmPkr'] as num).toDouble(),
      expectedYieldIncreasePct:
          (json['expectedYieldIncreasePct'] as num).toDouble(),
      roiNote: json['roiNote'] as String,
      nextCheckupDays: (json['nextCheckupDays'] as num).toInt(),
      generatedAt: json['generatedAt'] as String?,
      district: json['district'] as String?,
      crop: json['crop'] as String?,
    );

Map<String, dynamic> _$$AIAdviceImplToJson(_$AIAdviceImpl instance) =>
    <String, dynamic>{
      'alertUrdu': instance.alertUrdu,
      'alertEnglish': instance.alertEnglish,
      'diagnosis': instance.diagnosis,
      'confidencePct': instance.confidencePct,
      'actionSteps': instance.actionSteps,
      'medicines': instance.medicines,
      'fertilizerAdvice': instance.fertilizerAdvice,
      'irrigationAdvice': instance.irrigationAdvice,
      'totalCostPerAcrePkr': instance.totalCostPerAcrePkr,
      'totalCostForFarmPkr': instance.totalCostForFarmPkr,
      'expectedYieldIncreasePct': instance.expectedYieldIncreasePct,
      'roiNote': instance.roiNote,
      'nextCheckupDays': instance.nextCheckupDays,
      'generatedAt': instance.generatedAt,
      'district': instance.district,
      'crop': instance.crop,
    };

_$AIAdviceRequestImpl _$$AIAdviceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AIAdviceRequestImpl(
      district: json['district'] as String,
      crop: json['crop'] as String,
      province: json['province'] as String,
      season: json['season'] as String,
      farmSizeAcres: (json['farmSizeAcres'] as num).toDouble(),
      ndvi: (json['ndvi'] as num).toDouble(),
      rainfallMm: (json['rainfallMm'] as num).toDouble(),
      tempMaxC: (json['tempMaxC'] as num).toDouble(),
      soilMoisturePct: (json['soilMoisturePct'] as num).toDouble(),
      waterTableM: (json['waterTableM'] as num).toDouble(),
      symptoms:
          (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      language: json['language'] as String? ?? 'en',
    );

Map<String, dynamic> _$$AIAdviceRequestImplToJson(
        _$AIAdviceRequestImpl instance) =>
    <String, dynamic>{
      'district': instance.district,
      'crop': instance.crop,
      'province': instance.province,
      'season': instance.season,
      'farmSizeAcres': instance.farmSizeAcres,
      'ndvi': instance.ndvi,
      'rainfallMm': instance.rainfallMm,
      'tempMaxC': instance.tempMaxC,
      'soilMoisturePct': instance.soilMoisturePct,
      'waterTableM': instance.waterTableM,
      'symptoms': instance.symptoms,
      'language': instance.language,
    };
