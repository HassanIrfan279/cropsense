import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_data.freezed.dart';
part 'weather_data.g.dart';

@freezed
class WeatherData with _$WeatherData {
  const factory WeatherData({
    required String district,
    required double temperature,
    required double rainfall30day,
    required double humidity,
    required double windSpeed,
    required double tempMaxForecast,
    required double tempMinForecast,
    required double evapotranspiration,
    required bool heatStressAlert,
    required bool droughtAlert,
    required double ndviEstimate,
    @Default('Open-Meteo') String dataSource,
    @Default('') String fetchedAt,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
}
