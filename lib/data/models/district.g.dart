// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'district.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DistrictImpl _$$DistrictImplFromJson(Map<String, dynamic> json) =>
    _$DistrictImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      province: json['province'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['riskLevel'] as String? ?? 'good',
      currentNdvi: (json['currentNdvi'] as num?)?.toDouble() ?? 0.0,
      currentYieldForecast:
          (json['currentYieldForecast'] as num?)?.toDouble() ?? 0.0,
      confidenceLow: (json['confidenceLow'] as num?)?.toDouble() ?? 0.0,
      confidenceHigh: (json['confidenceHigh'] as num?)?.toDouble() ?? 0.0,
      forecastCrop: json['forecastCrop'] as String? ?? 'wheat',
      lastUpdated: json['lastUpdated'] as String?,
    );

Map<String, dynamic> _$$DistrictImplToJson(_$DistrictImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'province': instance.province,
      'lat': instance.lat,
      'lng': instance.lng,
      'riskScore': instance.riskScore,
      'riskLevel': instance.riskLevel,
      'currentNdvi': instance.currentNdvi,
      'currentYieldForecast': instance.currentYieldForecast,
      'confidenceLow': instance.confidenceLow,
      'confidenceHigh': instance.confidenceHigh,
      'forecastCrop': instance.forecastCrop,
      'lastUpdated': instance.lastUpdated,
    };
