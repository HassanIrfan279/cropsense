// lib/providers/district_provider.dart
//
// Provides the list of all Pakistan districts with current readings.
// Cache-first: reads Hive → if stale/missing, fetches from API.
// Any screen can watch this with: ref.watch(districtProvider)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/data/models/district.dart';

// ── Selected district (which one the user tapped on the map) ──────────
// Starts as null (nothing selected). Map screen sets this on polygon tap.
final selectedDistrictProvider = StateProvider<District?>((ref) => null);

// ── Selected crop (global — shared across Map, Analytics, AI screens) ─
final selectedCropProvider = StateProvider<String>((ref) => 'wheat');

// ── Main district list provider ───────────────────────────────────────
final districtProvider = AsyncNotifierProvider<DistrictNotifier, List<District>>(
  DistrictNotifier.new,
);

class DistrictNotifier extends AsyncNotifier<List<District>> {
  @override
  Future<List<District>> build() async {
    return _loadDistricts();
  }

  Future<List<District>> _loadDistricts() async {
    final cache = ref.read(cacheServiceProvider);
    final api   = ref.read(apiServiceProvider);

    // Step 1: Try to read from Hive cache first (valid for 24 hours).
    // This makes the app feel instant — no loading spinner on repeat visits.
    final cached = cache.getCachedDistrictList();
    if (cached != null) {
      return cached
          .map((json) => District.fromJson(json))
          .toList();
    }

    // Step 2: Cache is empty or stale — fetch from the FastAPI backend.
    try {
      final districts = await api.getDistricts();

      // Save to cache so next launch is instant
      await cache.cacheDistrictList(
        districts.map((d) => d.toJson()).toList(),
      );

      return districts;
    } catch (e) {
      // Step 3: If API call fails (no internet), return mock data so the
      // app doesn't show a blank screen. Real data loads when back online.
      return _mockDistricts();
    }
  }

  // Force a fresh fetch (called when user pulls to refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadDistricts);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MOCK DATA — shown when API is unreachable (offline / backend not started)
// This lets us build and test the UI before the backend exists.
// ─────────────────────────────────────────────────────────────────────────
List<District> _mockDistricts() {
  return [
    const District(
      id: 'faisalabad',
      name: 'Faisalabad',
      province: 'Punjab',
      lat: 31.4504,
      lng: 73.1350,
      riskScore: 35.0,
      riskLevel: 'watch',
      currentNdvi: 0.62,
      currentYieldForecast: 2.3,
      confidenceLow: 2.0,
      confidenceHigh: 2.6,
      forecastCrop: 'wheat',
    ),
    const District(
      id: 'lahore',
      name: 'Lahore',
      province: 'Punjab',
      lat: 31.5497,
      lng: 74.3436,
      riskScore: 20.0,
      riskLevel: 'good',
      currentNdvi: 0.71,
      currentYieldForecast: 2.7,
      confidenceLow: 2.4,
      confidenceHigh: 3.0,
      forecastCrop: 'wheat',
    ),
    const District(
      id: 'multan',
      name: 'Multan',
      province: 'Punjab',
      lat: 30.1978,
      lng: 71.4711,
      riskScore: 55.0,
      riskLevel: 'high',
      currentNdvi: 0.48,
      currentYieldForecast: 1.8,
      confidenceLow: 1.5,
      confidenceHigh: 2.1,
      forecastCrop: 'cotton',
    ),
    const District(
      id: 'karachi',
      name: 'Karachi',
      province: 'Sindh',
      lat: 24.8607,
      lng: 67.0011,
      riskScore: 70.0,
      riskLevel: 'high',
      currentNdvi: 0.38,
      currentYieldForecast: 1.4,
      confidenceLow: 1.1,
      confidenceHigh: 1.7,
      forecastCrop: 'rice',
    ),
    const District(
      id: 'peshawar',
      name: 'Peshawar',
      province: 'Khyber Pakhtunkhwa',
      lat: 34.0151,
      lng: 71.5249,
      riskScore: 28.0,
      riskLevel: 'above',
      currentNdvi: 0.65,
      currentYieldForecast: 2.1,
      confidenceLow: 1.9,
      confidenceHigh: 2.4,
      forecastCrop: 'maize',
    ),
    const District(
      id: 'quetta',
      name: 'Quetta',
      province: 'Balochistan',
      lat: 30.1798,
      lng: 66.9750,
      riskScore: 82.0,
      riskLevel: 'critical',
      currentNdvi: 0.29,
      currentYieldForecast: 0.9,
      confidenceLow: 0.6,
      confidenceHigh: 1.2,
      forecastCrop: 'wheat',
    ),
  ];
}