content = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/data/models/yield_data.dart';

final cropYieldProvider = AsyncNotifierProviderFamily
    CropYieldNotifier,
    YieldDataResponse,
    (String, String)>(CropYieldNotifier.new);

class CropYieldNotifier
    extends FamilyAsyncNotifier<YieldDataResponse, (String, String)> {
  @override
  Future<YieldDataResponse> build((String, String) arg) async {
    return _load(arg.$1, arg.$2);
  }

  Future<YieldDataResponse> _load(String district, String crop) async {
    final cache = ref.read(cacheServiceProvider);
    final api = ref.read(apiServiceProvider);

    final cached = cache.getCachedYieldData(district, crop);
    if (cached != null) {
      return YieldDataResponse.fromJson(cached);
    }

    try {
      final response = await api.getYieldData(
        district: district,
        crop: crop,
      );
      await cache.cacheYieldData(district, crop, response.toJson());
      return response;
    } catch (e) {
      return _mock(district, crop);
    }
  }
}

YieldDataResponse _mock(String district, String crop) {
  final years = List.generate(19, (i) => 2005 + i);
  final data = years.map((yr) {
    final p = (yr - 2005) / 18.0;
    final base = 1.8 + (p * 0.6);
    final v = 0.3 * (yr % 3 == 0 ? -1 : 1);
    return YieldData(
      district: district,
      crop: crop,
      year: yr,
      yieldTAcre: (base + v).clamp(0.8, 3.5),
      ndvi: (0.45 + p * 0.25).clamp(0.2, 0.9),
      rainfallMm: 180 + (yr % 5) * 40.0,
      tempMaxC: 36 + (yr % 3) * 2.0,
      tempMinC: 18 + (yr % 4) * 1.5,
      soilMoisturePct: 35 + (yr % 6) * 5.0,
      predictedYield: base + v * 0.8,
    );
  }).toList();
  return YieldDataResponse(district: district, crop: crop, data: data);
}
"""

with open('lib/providers/yield_provider.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('yield_provider.dart written successfully!')