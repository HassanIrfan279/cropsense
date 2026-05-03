import 'package:cropsense/app.dart';
import 'package:cropsense/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FuturePredictionForm {
  final List<String> crops;
  final String district;
  final double farmAcres;
  final String soilType;
  final String waterAvailability;
  final double budgetPkr;
  final int predictionYears;

  const FuturePredictionForm({
    this.crops = const ['wheat', 'maize'],
    this.district = 'faisalabad',
    this.farmAcres = 5.0,
    this.soilType = 'loam',
    this.waterAvailability = 'medium',
    this.budgetPkr = 150000.0,
    this.predictionYears = 5,
  });

  FuturePredictionForm copyWith({
    List<String>? crops,
    String? district,
    double? farmAcres,
    String? soilType,
    String? waterAvailability,
    double? budgetPkr,
    int? predictionYears,
  }) {
    return FuturePredictionForm(
      crops: crops ?? this.crops,
      district: district ?? this.district,
      farmAcres: farmAcres ?? this.farmAcres,
      soilType: soilType ?? this.soilType,
      waterAvailability: waterAvailability ?? this.waterAvailability,
      budgetPkr: budgetPkr ?? this.budgetPkr,
      predictionYears: predictionYears ?? this.predictionYears,
    );
  }

  Map<String, dynamic> toJson() => {
        'crops': crops,
        'district': district,
        'farmAcres': farmAcres,
        'soilType': soilType,
        'waterAvailability': waterAvailability,
        'budgetPkr': budgetPkr,
        'predictionYears': predictionYears,
      };
}

final futurePredictionFormProvider =
    StateNotifierProvider<FuturePredictionFormNotifier, FuturePredictionForm>(
  (ref) => FuturePredictionFormNotifier(),
);

class FuturePredictionFormNotifier extends StateNotifier<FuturePredictionForm> {
  FuturePredictionFormNotifier() : super(const FuturePredictionForm());

  void toggleCrop(String crop) {
    final next = List<String>.from(state.crops);
    if (next.contains(crop)) {
      next.remove(crop);
    } else {
      next.add(crop);
    }
    if (next.isEmpty) next.add(crop);
    state = state.copyWith(crops: next);
  }

  void setDistrict(String value) => state = state.copyWith(district: value);
  void setFarmAcres(double value) => state = state.copyWith(farmAcres: value);
  void setSoilType(String value) => state = state.copyWith(soilType: value);
  void setWaterAvailability(String value) =>
      state = state.copyWith(waterAvailability: value);
  void setBudget(double value) => state = state.copyWith(budgetPkr: value);
  void setPredictionYears(int value) =>
      state = state.copyWith(predictionYears: value == 10 ? 10 : 5);
}

final futurePredictionProvider = StateNotifierProvider<FuturePredictionNotifier,
    AsyncValue<Map<String, dynamic>?>>(
  (ref) => FuturePredictionNotifier(ref),
);

class FuturePredictionNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref _ref;

  FuturePredictionNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> predict() async {
    final form = _ref.read(futurePredictionFormProvider);
    state = const AsyncValue.loading();
    try {
      final data = await _ref.read(apiServiceProvider).getFuturePrediction(
            request: form.toJson(),
          );
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

String districtLabel(String id) {
  return AppDistricts.all.firstWhere(
    (district) => district['id'] == id,
    orElse: () => {'label': id},
  )['label']!;
}

String cropLabel(String id) {
  return AppCrops.all.firstWhere(
    (crop) => crop['id'] == id,
    orElse: () => {'label': id},
  )['label']!;
}
