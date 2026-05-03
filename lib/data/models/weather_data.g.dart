// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherDataImpl _$$WeatherDataImplFromJson(Map<String, dynamic> json) =>
    _$WeatherDataImpl(
      district: json['district'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      rainfall30day: (json['rainfall30day'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      tempMaxForecast: (json['tempMaxForecast'] as num).toDouble(),
      tempMinForecast: (json['tempMinForecast'] as num).toDouble(),
      evapotranspiration: (json['evapotranspiration'] as num).toDouble(),
      heatStressAlert: json['heatStressAlert'] as bool,
      droughtAlert: json['droughtAlert'] as bool,
      ndviEstimate: (json['ndviEstimate'] as num).toDouble(),
      dataSource: json['dataSource'] as String? ?? 'Open-Meteo',
      fetchedAt: json['fetchedAt'] as String? ?? '',
    );

Map<String, dynamic> _$$WeatherDataImplToJson(_$WeatherDataImpl instance) =>
    <String, dynamic>{
      'district': instance.district,
      'temperature': instance.temperature,
      'rainfall30day': instance.rainfall30day,
      'humidity': instance.humidity,
      'windSpeed': instance.windSpeed,
      'tempMaxForecast': instance.tempMaxForecast,
      'tempMinForecast': instance.tempMinForecast,
      'evapotranspiration': instance.evapotranspiration,
      'heatStressAlert': instance.heatStressAlert,
      'droughtAlert': instance.droughtAlert,
      'ndviEstimate': instance.ndviEstimate,
      'dataSource': instance.dataSource,
      'fetchedAt': instance.fetchedAt,
    };
