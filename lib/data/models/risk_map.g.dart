// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RiskMapEntryImpl _$$RiskMapEntryImplFromJson(Map<String, dynamic> json) =>
    _$RiskMapEntryImpl(
      district: json['district'] as String,
      districtName: json['districtName'] as String,
      province: json['province'] as String,
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      riskScore: (json['riskScore'] as num).toDouble(),
      cropYields: (json['cropYields'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      ndvi: (json['ndvi'] as num?)?.toDouble() ?? 0.0,
      alertCount: (json['alertCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RiskMapEntryImplToJson(_$RiskMapEntryImpl instance) =>
    <String, dynamic>{
      'district': instance.district,
      'districtName': instance.districtName,
      'province': instance.province,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'riskScore': instance.riskScore,
      'cropYields': instance.cropYields,
      'ndvi': instance.ndvi,
      'alertCount': instance.alertCount,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.good: 'good',
  RiskLevel.above: 'above',
  RiskLevel.watch: 'watch',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

_$RiskMapResponseImpl _$$RiskMapResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RiskMapResponseImpl(
      districts: (json['districts'] as List<dynamic>)
          .map((e) => RiskMapEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: json['generatedAt'] as String,
      nationalRiskLevel: json['nationalRiskLevel'] as String? ?? 'good',
      criticalCount: (json['criticalCount'] as num?)?.toInt() ?? 0,
      highCount: (json['highCount'] as num?)?.toInt() ?? 0,
      watchCount: (json['watchCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RiskMapResponseImplToJson(
        _$RiskMapResponseImpl instance) =>
    <String, dynamic>{
      'districts': instance.districts,
      'generatedAt': instance.generatedAt,
      'nationalRiskLevel': instance.nationalRiskLevel,
      'criticalCount': instance.criticalCount,
      'highCount': instance.highCount,
      'watchCount': instance.watchCount,
    };
