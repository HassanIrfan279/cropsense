import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/data/models/risk_map.dart';

final riskMapProvider = AsyncNotifierProvider<RiskMapNotifier, RiskMapResponse>(
  RiskMapNotifier.new,
);

class RiskMapNotifier extends AsyncNotifier<RiskMapResponse> {
  @override
  Future<RiskMapResponse> build() async => _loadRiskMap();

  Future<RiskMapResponse> _loadRiskMap() async {
    final cache = ref.read(cacheServiceProvider);
    final api   = ref.read(apiServiceProvider);
    final cached = cache.getCachedRiskMap();
    if (cached != null) return RiskMapResponse.fromJson(cached);
    try {
      final riskMap = await api.getRiskMap();
      await cache.cacheRiskMap(riskMap.toJson());
      return riskMap;
    } catch (_) {
      return _mockRiskMap();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadRiskMap);
  }
}

RiskMapResponse _mockRiskMap() {
  return RiskMapResponse(
    generatedAt: DateTime.now().toIso8601String(),
    nationalRiskLevel: 'watch',
    criticalCount: 3,
    highCount: 7,
    watchCount: 10,
    districts: const [
      // ── Punjab ──────────────────────────────────────────────────────
      RiskMapEntry(district: 'lahore',      districtName: 'Lahore',      province: 'Punjab',
        riskLevel: RiskLevel.good,     riskScore: 20.0, ndvi: 0.71, alertCount: 0,
        cropYields: {'wheat': 2.7, 'rice': 2.1}),
      RiskMapEntry(district: 'faisalabad',  districtName: 'Faisalabad',  province: 'Punjab',
        riskLevel: RiskLevel.watch,    riskScore: 35.0, ndvi: 0.62, alertCount: 1,
        cropYields: {'wheat': 2.3, 'cotton': 1.9, 'rice': 1.5}),
      RiskMapEntry(district: 'multan',      districtName: 'Multan',      province: 'Punjab',
        riskLevel: RiskLevel.high,     riskScore: 55.0, ndvi: 0.48, alertCount: 3,
        cropYields: {'wheat': 1.8, 'cotton': 1.4, 'sugarcane': 2.2}),
      RiskMapEntry(district: 'rawalpindi',  districtName: 'Rawalpindi',  province: 'Punjab',
        riskLevel: RiskLevel.good,     riskScore: 18.0, ndvi: 0.68, alertCount: 0,
        cropYields: {'wheat': 2.5, 'maize': 1.9}),
      RiskMapEntry(district: 'gujranwala', districtName: 'Gujranwala',  province: 'Punjab',
        riskLevel: RiskLevel.watch,    riskScore: 30.0, ndvi: 0.65, alertCount: 1,
        cropYields: {'wheat': 2.4, 'rice': 2.0}),
      RiskMapEntry(district: 'sialkot',    districtName: 'Sialkot',     province: 'Punjab',
        riskLevel: RiskLevel.good,     riskScore: 22.0, ndvi: 0.70, alertCount: 0,
        cropYields: {'wheat': 2.6, 'rice': 2.2}),
      RiskMapEntry(district: 'bahawalpur', districtName: 'Bahawalpur',  province: 'Punjab',
        riskLevel: RiskLevel.high,     riskScore: 60.0, ndvi: 0.42, alertCount: 4,
        cropYields: {'wheat': 1.6, 'cotton': 1.2}),
      RiskMapEntry(district: 'sargodha',   districtName: 'Sargodha',    province: 'Punjab',
        riskLevel: RiskLevel.watch,    riskScore: 40.0, ndvi: 0.58, alertCount: 2,
        cropYields: {'wheat': 2.1, 'cotton': 1.7}),
      RiskMapEntry(district: 'sheikhupura',districtName: 'Sheikhupura', province: 'Punjab',
        riskLevel: RiskLevel.good,     riskScore: 25.0, ndvi: 0.66, alertCount: 0,
        cropYields: {'wheat': 2.5, 'rice': 2.1}),
      RiskMapEntry(district: 'jhang',      districtName: 'Jhang',       province: 'Punjab',
        riskLevel: RiskLevel.above,    riskScore: 45.0, ndvi: 0.52, alertCount: 2,
        cropYields: {'wheat': 2.0, 'cotton': 1.5}),
      RiskMapEntry(district: 'vehari',     districtName: 'Vehari',      province: 'Punjab',
        riskLevel: RiskLevel.above,    riskScore: 50.0, ndvi: 0.50, alertCount: 2,
        cropYields: {'wheat': 1.9, 'cotton': 1.4}),
      RiskMapEntry(district: 'sahiwal',    districtName: 'Sahiwal',     province: 'Punjab',
        riskLevel: RiskLevel.watch,    riskScore: 38.0, ndvi: 0.60, alertCount: 1,
        cropYields: {'wheat': 2.2, 'rice': 1.8}),
      RiskMapEntry(district: 'okara',      districtName: 'Okara',       province: 'Punjab',
        riskLevel: RiskLevel.watch,    riskScore: 32.0, ndvi: 0.63, alertCount: 1,
        cropYields: {'wheat': 2.3, 'rice': 1.9}),
      RiskMapEntry(district: 'kasur',      districtName: 'Kasur',       province: 'Punjab',
        riskLevel: RiskLevel.good,     riskScore: 28.0, ndvi: 0.67, alertCount: 0,
        cropYields: {'wheat': 2.4, 'rice': 2.0}),
      // ── Sindh ───────────────────────────────────────────────────────
      RiskMapEntry(district: 'karachi',    districtName: 'Karachi',     province: 'Sindh',
        riskLevel: RiskLevel.high,     riskScore: 70.0, ndvi: 0.38, alertCount: 4,
        cropYields: {'rice': 1.4, 'sugarcane': 1.8}),
      RiskMapEntry(district: 'hyderabad',  districtName: 'Hyderabad',   province: 'Sindh',
        riskLevel: RiskLevel.above,    riskScore: 48.0, ndvi: 0.52, alertCount: 2,
        cropYields: {'wheat': 1.9, 'rice': 1.6, 'sugarcane': 2.0}),
      RiskMapEntry(district: 'sukkur',     districtName: 'Sukkur',      province: 'Sindh',
        riskLevel: RiskLevel.watch,    riskScore: 42.0, ndvi: 0.56, alertCount: 2,
        cropYields: {'wheat': 2.0, 'cotton': 1.5}),
      RiskMapEntry(district: 'larkana',    districtName: 'Larkana',     province: 'Sindh',
        riskLevel: RiskLevel.above,    riskScore: 52.0, ndvi: 0.50, alertCount: 2,
        cropYields: {'rice': 1.8, 'sugarcane': 2.1}),
      RiskMapEntry(district: 'nawabshah',  districtName: 'Nawabshah',   province: 'Sindh',
        riskLevel: RiskLevel.high,     riskScore: 58.0, ndvi: 0.44, alertCount: 3,
        cropYields: {'wheat': 1.7, 'cotton': 1.3}),
      RiskMapEntry(district: 'mirpur-khas',districtName: 'Mirpur Khas', province: 'Sindh',
        riskLevel: RiskLevel.above,    riskScore: 46.0, ndvi: 0.53, alertCount: 2,
        cropYields: {'wheat': 1.9, 'rice': 1.5}),
      RiskMapEntry(district: 'tharparkar', districtName: 'Tharparkar',  province: 'Sindh',
        riskLevel: RiskLevel.critical, riskScore: 85.0, ndvi: 0.22, alertCount: 7,
        cropYields: {'wheat': 0.8}),
      RiskMapEntry(district: 'kashmore',   districtName: 'Kashmore',    province: 'Sindh',
        riskLevel: RiskLevel.watch,    riskScore: 36.0, ndvi: 0.60, alertCount: 1,
        cropYields: {'wheat': 2.1, 'rice': 1.7}),
      // ── Khyber Pakhtunkhwa ──────────────────────────────────────────
      RiskMapEntry(district: 'peshawar',   districtName: 'Peshawar',    province: 'Khyber Pakhtunkhwa',
        riskLevel: RiskLevel.above,    riskScore: 28.0, ndvi: 0.65, alertCount: 1,
        cropYields: {'maize': 2.1, 'wheat': 2.3}),
      RiskMapEntry(district: 'mardan',     districtName: 'Mardan',      province: 'Khyber Pakhtunkhwa',
        riskLevel: RiskLevel.good,     riskScore: 24.0, ndvi: 0.68, alertCount: 0,
        cropYields: {'maize': 2.3, 'wheat': 2.5}),
      RiskMapEntry(district: 'swat',       districtName: 'Swat',        province: 'Khyber Pakhtunkhwa',
        riskLevel: RiskLevel.good,     riskScore: 20.0, ndvi: 0.72, alertCount: 0,
        cropYields: {'maize': 2.5, 'rice': 2.2}),
      RiskMapEntry(district: 'abbottabad', districtName: 'Abbottabad',  province: 'Khyber Pakhtunkhwa',
        riskLevel: RiskLevel.good,     riskScore: 18.0, ndvi: 0.74, alertCount: 0,
        cropYields: {'maize': 2.4, 'wheat': 2.6}),
      RiskMapEntry(district: 'charsadda',  districtName: 'Charsadda',   province: 'Khyber Pakhtunkhwa',
        riskLevel: RiskLevel.watch,    riskScore: 34.0, ndvi: 0.62, alertCount: 1,
        cropYields: {'maize': 2.0, 'wheat': 2.2}),
      RiskMapEntry(district: 'dera-ismail-khan', districtName: 'Dera Ismail Khan', province: 'Khyber Pakhtunkhwa',
        riskLevel: RiskLevel.above,    riskScore: 45.0, ndvi: 0.53, alertCount: 2,
        cropYields: {'wheat': 1.9, 'maize': 1.7}),
      // ── Balochistan ─────────────────────────────────────────────────
      RiskMapEntry(district: 'quetta',     districtName: 'Quetta',      province: 'Balochistan',
        riskLevel: RiskLevel.critical, riskScore: 82.0, ndvi: 0.29, alertCount: 6,
        cropYields: {'wheat': 0.9}),
      RiskMapEntry(district: 'turbat',     districtName: 'Turbat',      province: 'Balochistan',
        riskLevel: RiskLevel.critical, riskScore: 88.0, ndvi: 0.18, alertCount: 8,
        cropYields: {'wheat': 0.7}),
      RiskMapEntry(district: 'khuzdar',    districtName: 'Khuzdar',     province: 'Balochistan',
        riskLevel: RiskLevel.high,     riskScore: 62.0, ndvi: 0.38, alertCount: 4,
        cropYields: {'wheat': 1.2}),
      RiskMapEntry(district: 'hub',        districtName: 'Hub',         province: 'Balochistan',
        riskLevel: RiskLevel.high,     riskScore: 65.0, ndvi: 0.36, alertCount: 4,
        cropYields: {'wheat': 1.1}),
      RiskMapEntry(district: 'loralai',    districtName: 'Loralai',     province: 'Balochistan',
        riskLevel: RiskLevel.above,    riskScore: 50.0, ndvi: 0.48, alertCount: 2,
        cropYields: {'wheat': 1.5}),
      RiskMapEntry(district: 'zhob',       districtName: 'Zhob',        province: 'Balochistan',
        riskLevel: RiskLevel.above,    riskScore: 46.0, ndvi: 0.50, alertCount: 2,
        cropYields: {'wheat': 1.6}),
      RiskMapEntry(district: 'naseerabad', districtName: 'Naseerabad',  province: 'Balochistan',
        riskLevel: RiskLevel.watch,    riskScore: 38.0, ndvi: 0.58, alertCount: 1,
        cropYields: {'wheat': 1.9, 'rice': 1.4}),
      RiskMapEntry(district: 'sibi',       districtName: 'Sibi',        province: 'Balochistan',
        riskLevel: RiskLevel.high,     riskScore: 58.0, ndvi: 0.42, alertCount: 3,
        cropYields: {'wheat': 1.3}),
    ],
  );
}
