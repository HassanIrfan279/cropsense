// lib/providers/map_provider.dart
//
// Manages the Pakistan risk map data.
// Provides colored district data for the choropleth map.
// Cache-first: 1 hour freshness (risk levels change more often than district info).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/data/models/risk_map.dart';

// ── Risk map data provider ────────────────────────────────────────────
final riskMapProvider = AsyncNotifierProvider<RiskMapNotifier, RiskMapResponse>(
  RiskMapNotifier.new,
);

class RiskMapNotifier extends AsyncNotifier<RiskMapResponse> {
  @override
  Future<RiskMapResponse> build() async {
    return _loadRiskMap();
  }

  Future<RiskMapResponse> _loadRiskMap() async {
    final cache = ref.read(cacheServiceProvider);
    final api   = ref.read(apiServiceProvider);

    // Try cache first (1 hour freshness)
    final cached = cache.getCachedRiskMap();
    if (cached != null) {
      return RiskMapResponse.fromJson(cached);
    }

    // Fetch from API
    try {
      final riskMap = await api.getRiskMap();
      await cache.cacheRiskMap(riskMap.toJson());
      return riskMap;
    } catch (e) {
      // Return mock risk map so the map screen still renders offline
      return _mockRiskMap();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadRiskMap);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MOCK RISK MAP — used when API is offline during development
// ─────────────────────────────────────────────────────────────────────────
RiskMapResponse _mockRiskMap() {
  return RiskMapResponse(
    generatedAt: DateTime.now().toIso8601String(),
    nationalRiskLevel: 'watch',
    criticalCount: 2,
    highCount: 5,
    watchCount: 8,
    districts: [
      const RiskMapEntry(
        district: 'faisalabad',
        districtName: 'Faisalabad',
        province: 'Punjab',
        riskLevel: RiskLevel.watch,
        riskScore: 35.0,
        ndvi: 0.62,
        alertCount: 1,
        cropYields: {'wheat': 2.3, 'cotton': 1.9, 'rice': 1.5},
      ),
      const RiskMapEntry(
        district: 'lahore',
        districtName: 'Lahore',
        province: 'Punjab',
        riskLevel: RiskLevel.good,
        riskScore: 20.0,
        ndvi: 0.71,
        alertCount: 0,
        cropYields: {'wheat': 2.7, 'rice': 2.1},
      ),
      const RiskMapEntry(
        district: 'multan',
        districtName: 'Multan',
        province: 'Punjab',
        riskLevel: RiskLevel.high,
        riskScore: 55.0,
        ndvi: 0.48,
        alertCount: 3,
        cropYields: {'wheat': 1.8, 'cotton': 1.4, 'sugarcane': 2.2},
      ),
      const RiskMapEntry(
        district: 'karachi',
        districtName: 'Karachi',
        province: 'Sindh',
        riskLevel: RiskLevel.high,
        riskScore: 70.0,
        ndvi: 0.38,
        alertCount: 4,
        cropYields: {'rice': 1.4, 'sugarcane': 1.8},
      ),
      const RiskMapEntry(
        district: 'quetta',
        districtName: 'Quetta',
        province: 'Balochistan',
        riskLevel: RiskLevel.critical,
        riskScore: 82.0,
        ndvi: 0.29,
        alertCount: 6,
        cropYields: {'wheat': 0.9},
      ),
      const RiskMapEntry(
        district: 'peshawar',
        districtName: 'Peshawar',
        province: 'Khyber Pakhtunkhwa',
        riskLevel: RiskLevel.above,
        riskScore: 28.0,
        ndvi: 0.65,
        alertCount: 1,
        cropYields: {'maize': 2.1, 'wheat': 2.3},
      ),
    ],
  );
}