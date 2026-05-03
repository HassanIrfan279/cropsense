import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/data/models/weather_data.dart';

final weatherProvider = AsyncNotifierProvider.family<
    WeatherNotifier, WeatherData, String>(WeatherNotifier.new);

class WeatherNotifier
    extends FamilyAsyncNotifier<WeatherData, String> {
  @override
  Future<WeatherData> build(String district) => _load(district);

  Future<WeatherData> _load(String district) async {
    final cache = ref.read(cacheServiceProvider);
    final api   = ref.read(apiServiceProvider);

    final cached = cache.getCachedWeather(district);
    if (cached != null) {
      return _fromMap(cached, district);
    }

    try {
      final data = await api.getWeather(district: district);
      await cache.cacheWeather(district, _toMap(data));
      return data;
    } catch (_) {
      return _estimate(district);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(arg));
  }
}

WeatherData _fromMap(Map<String, dynamic> m, String district) {
  return WeatherData(
    district:          m['district'] as String? ?? district,
    temperature:       (m['temperature'] as num).toDouble(),
    rainfall30day:     (m['rainfall30day'] as num).toDouble(),
    humidity:          (m['humidity'] as num).toDouble(),
    windSpeed:         (m['windSpeed'] as num).toDouble(),
    tempMaxForecast:   (m['tempMaxForecast'] as num).toDouble(),
    tempMinForecast:   (m['tempMinForecast'] as num).toDouble(),
    evapotranspiration:(m['evapotranspiration'] as num).toDouble(),
    heatStressAlert:   m['heatStressAlert'] as bool? ?? false,
    droughtAlert:      m['droughtAlert'] as bool? ?? false,
    ndviEstimate:      (m['ndviEstimate'] as num).toDouble(),
    dataSource:        m['dataSource'] as String? ?? 'Open-Meteo',
    fetchedAt:         m['fetchedAt'] as String? ?? '',
  );
}

Map<String, dynamic> _toMap(WeatherData d) => {
  'district':          d.district,
  'temperature':       d.temperature,
  'rainfall30day':     d.rainfall30day,
  'humidity':          d.humidity,
  'windSpeed':         d.windSpeed,
  'tempMaxForecast':   d.tempMaxForecast,
  'tempMinForecast':   d.tempMinForecast,
  'evapotranspiration':d.evapotranspiration,
  'heatStressAlert':   d.heatStressAlert,
  'droughtAlert':      d.droughtAlert,
  'ndviEstimate':      d.ndviEstimate,
  'dataSource':        d.dataSource,
  'fetchedAt':         d.fetchedAt,
};

// Fallback estimate when API is unreachable
WeatherData _estimate(String district) {
  const warmDistricts = {'karachi', 'hyderabad', 'sukkur', 'turbat', 'nawabshah'};
  const coldDistricts = {'quetta', 'swat', 'abbottabad', 'mardan'};
  final d = district.toLowerCase();
  double temp = coldDistricts.contains(d) ? 22.0 : (warmDistricts.contains(d) ? 34.0 : 30.0);
  double rain = d == 'tharparkar' ? 20.0 : (coldDistricts.contains(d) ? 90.0 : 60.0);
  final ndvi = ((rain / 300.0) * 0.8 + 0.2).clamp(0.1, 0.9);
  return WeatherData(
    district:          district,
    temperature:       temp,
    rainfall30day:     rain,
    humidity:          55.0,
    windSpeed:         12.0,
    tempMaxForecast:   temp + 3.0,
    tempMinForecast:   temp - 8.0,
    evapotranspiration:4.5,
    heatStressAlert:   temp > 40.0,
    droughtAlert:      rain < 50.0,
    ndviEstimate:      ndvi,
    dataSource:        'Estimated',
    fetchedAt:         DateTime.now().toIso8601String(),
  );
}
