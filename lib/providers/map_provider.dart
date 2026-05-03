import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/data/models/risk_map.dart';

final riskMapProvider = AsyncNotifierProvider<RiskMapNotifier, RiskMapResponse>(
  RiskMapNotifier.new,
);

class RiskMapNotifier extends AsyncNotifier<RiskMapResponse> {
  String _crop = 'wheat';
  int _year = DataConstants.endYear;

  String get selectedCrop => _crop;
  int get selectedYear => _year;

  @override
  Future<RiskMapResponse> build() => _loadRiskMap();

  Future<RiskMapResponse> _loadRiskMap() {
    final api = ref.read(apiServiceProvider);
    return api.getRiskMap(crop: _crop, year: _year);
  }

  Future<void> load({String? crop, int? year}) async {
    _crop = crop ?? _crop;
    _year = year ?? _year;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadRiskMap);
  }

  Future<void> refresh() => load();
}
