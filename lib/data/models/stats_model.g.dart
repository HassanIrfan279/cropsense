// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatsModelImpl _$$StatsModelImplFromJson(Map<String, dynamic> json) =>
    _$StatsModelImpl(
      district: json['district'] as String,
      crop: json['crop'] as String,
      mean: (json['mean'] as num).toDouble(),
      median: (json['median'] as num).toDouble(),
      std: (json['std'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      q1: (json['q1'] as num).toDouble(),
      q3: (json['q3'] as num).toDouble(),
      trendDirection:
          $enumDecode(_$TrendDirectionEnumMap, json['trendDirection']),
      trendSlope: (json['trendSlope'] as num).toDouble(),
      pValue: (json['pValue'] as num).toDouble(),
      rSquared: (json['rSquared'] as num).toDouble(),
      rmse: (json['rmse'] as num).toDouble(),
      droughtProbability:
          (json['droughtProbability'] as num?)?.toDouble() ?? 0.0,
      droughtThreshold: (json['droughtThreshold'] as num?)?.toDouble() ?? 1.0,
      sampleSize: (json['sampleSize'] as num?)?.toInt() ?? 19,
      yearRange: json['yearRange'] as String? ?? '2005–2023',
    );

Map<String, dynamic> _$$StatsModelImplToJson(_$StatsModelImpl instance) =>
    <String, dynamic>{
      'district': instance.district,
      'crop': instance.crop,
      'mean': instance.mean,
      'median': instance.median,
      'std': instance.std,
      'min': instance.min,
      'max': instance.max,
      'q1': instance.q1,
      'q3': instance.q3,
      'trendDirection': _$TrendDirectionEnumMap[instance.trendDirection]!,
      'trendSlope': instance.trendSlope,
      'pValue': instance.pValue,
      'rSquared': instance.rSquared,
      'rmse': instance.rmse,
      'droughtProbability': instance.droughtProbability,
      'droughtThreshold': instance.droughtThreshold,
      'sampleSize': instance.sampleSize,
      'yearRange': instance.yearRange,
    };

const _$TrendDirectionEnumMap = {
  TrendDirection.improving: 'improving',
  TrendDirection.stable: 'stable',
  TrendDirection.declining: 'declining',
};

_$StatsResponseImpl _$$StatsResponseImplFromJson(Map<String, dynamic> json) =>
    _$StatsResponseImpl(
      district: json['district'] as String,
      byCrop: (json['byCrop'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, StatsModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$StatsResponseImplToJson(_$StatsResponseImpl instance) =>
    <String, dynamic>{
      'district': instance.district,
      'byCrop': instance.byCrop,
    };
