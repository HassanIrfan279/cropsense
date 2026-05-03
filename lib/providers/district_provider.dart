import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/data/models/district.dart';

// ── Selected district (which one the user tapped on the map) ──────────
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
    final api = ref.read(apiServiceProvider);
    try {
      print('Fetching districts from API');
      final districts = await api.getDistricts();
      print('Districts loaded: ${districts.length}');
      return districts;
    } catch (e) {
      print('Districts API failed: $e — using fallback');
      return _fallbackDistricts();
    }
  }

  // Force a fresh fetch (called when user pulls to refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadDistricts);
  }
}

// Fallback shown only when the backend is unreachable.
List<District> _fallbackDistricts() {
  return const [
    District(
      id: 'faisalabad', name: 'Faisalabad', province: 'Punjab',
      lat: 31.45, lng: 73.13, riskScore: 35.0, riskLevel: 'watch',
      currentNdvi: 0.62, currentYieldForecast: 2.3,
      confidenceLow: 2.0, confidenceHigh: 2.6, forecastCrop: 'wheat',
    ),
    District(
      id: 'lahore', name: 'Lahore', province: 'Punjab',
      lat: 31.55, lng: 74.34, riskScore: 20.0, riskLevel: 'good',
      currentNdvi: 0.71, currentYieldForecast: 2.7,
      confidenceLow: 2.4, confidenceHigh: 3.0, forecastCrop: 'wheat',
    ),
    District(
      id: 'multan', name: 'Multan', province: 'Punjab',
      lat: 30.20, lng: 71.47, riskScore: 55.0, riskLevel: 'high',
      currentNdvi: 0.48, currentYieldForecast: 1.8,
      confidenceLow: 1.5, confidenceHigh: 2.1, forecastCrop: 'cotton',
    ),
    District(
      id: 'karachi', name: 'Karachi', province: 'Sindh',
      lat: 24.86, lng: 67.00, riskScore: 70.0, riskLevel: 'high',
      currentNdvi: 0.38, currentYieldForecast: 1.4,
      confidenceLow: 1.1, confidenceHigh: 1.7, forecastCrop: 'rice',
    ),
    District(
      id: 'quetta', name: 'Quetta', province: 'Balochistan',
      lat: 30.18, lng: 66.98, riskScore: 82.0, riskLevel: 'critical',
      currentNdvi: 0.29, currentYieldForecast: 0.9,
      confidenceLow: 0.6, confidenceHigh: 1.2, forecastCrop: 'wheat',
    ),
    District(
      id: 'peshawar', name: 'Peshawar', province: 'Khyber Pakhtunkhwa',
      lat: 34.02, lng: 71.52, riskScore: 28.0, riskLevel: 'above',
      currentNdvi: 0.65, currentYieldForecast: 2.1,
      confidenceLow: 1.9, confidenceHigh: 2.4, forecastCrop: 'maize',
    ),
  ];
}
