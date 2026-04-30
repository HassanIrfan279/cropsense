// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yield_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$YieldDataImpl _$$YieldDataImplFromJson(Map<String, dynamic> json) =>
    _$YieldDataImpl(
      district: json['district'] as String,
      crop: json['crop'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num?)?.toInt(),
      yieldTAcre: (json['yieldTAcre'] as num).toDouble(),
      ndvi: (json['ndvi'] as num).toDouble(),
      rainfallMm: (json['rainfallMm'] as num).toDouble(),
      tempMaxC: (json['tempMaxC'] as num).toDouble(),
      tempMinC: (json['tempMinC'] as num).toDouble(),
      soilMoisturePct: (json['soilMoisturePct'] as num).toDouble(),
      predictedYield: (json['predictedYield'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$YieldDataImplToJson(_$YieldDataImpl instance) =>
    <String, dynamic>{
      'district': instance.district,
      'crop': instance.crop,
      'year': instance.year,
      'month': instance.month,
      'yieldTAcre': instance.yieldTAcre,
      'ndvi': instance.ndvi,
      'rainfallMm': instance.rainfallMm,
      'tempMaxC': instance.tempMaxC,
      'tempMinC': instance.tempMinC,
      'soilMoisturePct': instance.soilMoisturePct,
      'predictedYield': instance.predictedYield,
    };

_$YieldDataResponseImpl _$$YieldDataResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$YieldDataResponseImpl(
      district: json['district'] as String,
      crop: json['crop'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => YieldData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$YieldDataResponseImplToJson(
        _$YieldDataResponseImpl instance) =>
    <String, dynamic>{
      'district': instance.district,
      'crop': instance.crop,
      'data': instance.data,
    };
