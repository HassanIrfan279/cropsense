// lib/providers/ai_advisor_provider.dart
//
// Manages the AI Advisor screen:
//   - Form field values (crop, district, NDVI sliders, symptoms)
//   - The async AI advice API call
//   - The result displayed in the right panel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/data/models/ai_advice.dart';

// ─────────────────────────────────────────────────────────────────────────
// FORM STATE
// All the values the farmer fills in on the AI Advisor form.
// Using a simple class (not Freezed) since it's only used in one provider.
// ─────────────────────────────────────────────────────────────────────────
class AdvisorFormState {
  final String district;
  final String crop;
  final String province;
  final String season;
  final double farmSizeAcres;
  final double ndvi;
  final double rainfallMm;
  final double tempMaxC;
  final double soilMoisturePct;
  final double waterTableM;
  final List<String> selectedSymptoms;

  const AdvisorFormState({
    this.district      = 'faisalabad',
    this.crop          = 'wheat',
    this.province      = 'Punjab',
    this.season        = 'Rabi',
    this.farmSizeAcres = 5.0,
    this.ndvi          = 0.5,
    this.rainfallMm    = 150.0,
    this.tempMaxC      = 35.0,
    this.soilMoisturePct = 40.0,
    this.waterTableM   = 8.0,
    this.selectedSymptoms = const [],
  });

  // Creates a copy with some fields changed — same pattern as Freezed
  AdvisorFormState copyWith({
    String? district,
    String? crop,
    String? province,
    String? season,
    double? farmSizeAcres,
    double? ndvi,
    double? rainfallMm,
    double? tempMaxC,
    double? soilMoisturePct,
    double? waterTableM,
    List<String>? selectedSymptoms,
  }) {
    return AdvisorFormState(
      district:         district         ?? this.district,
      crop:             crop             ?? this.crop,
      province:         province         ?? this.province,
      season:           season           ?? this.season,
      farmSizeAcres:    farmSizeAcres    ?? this.farmSizeAcres,
      ndvi:             ndvi             ?? this.ndvi,
      rainfallMm:       rainfallMm       ?? this.rainfallMm,
      tempMaxC:         tempMaxC         ?? this.tempMaxC,
      soilMoisturePct:  soilMoisturePct  ?? this.soilMoisturePct,
      waterTableM:      waterTableM      ?? this.waterTableM,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
    );
  }
}

// ── Form state provider ───────────────────────────────────────────────
final advisorFormProvider =
    StateNotifierProvider<AdvisorFormNotifier, AdvisorFormState>(
  (ref) => AdvisorFormNotifier(),
);

class AdvisorFormNotifier extends StateNotifier<AdvisorFormState> {
  AdvisorFormNotifier() : super(const AdvisorFormState());

  void setDistrict(String v) {
    final match = AppDistricts.all.firstWhere(
      (d) => d['id'] == v,
      orElse: () => {'id': v, 'label': v, 'province': 'Punjab'},
    );
    state = state.copyWith(district: v, province: match['province']);
  }
  void setCrop(String v)            => state = state.copyWith(crop: v);
  void setProvince(String v)        => state = state.copyWith(province: v);
  void setSeason(String v)          => state = state.copyWith(season: v);
  void setFarmSize(double v)        => state = state.copyWith(farmSizeAcres: v);
  void setNdvi(double v)            => state = state.copyWith(ndvi: v);
  void setRainfall(double v)        => state = state.copyWith(rainfallMm: v);
  void setTempMax(double v)         => state = state.copyWith(tempMaxC: v);
  void setSoilMoisture(double v)    => state = state.copyWith(soilMoisturePct: v);
  void setWaterTable(double v)      => state = state.copyWith(waterTableM: v);

  // Toggle a symptom on/off (multi-select)
  void toggleSymptom(String symptomId) {
    final current = List<String>.from(state.selectedSymptoms);
    if (current.contains(symptomId)) {
      current.remove(symptomId);
    } else {
      current.add(symptomId);
    }
    state = state.copyWith(selectedSymptoms: current);
  }

  void clearSymptoms() =>
      state = state.copyWith(selectedSymptoms: []);

  void resetForm() => state = const AdvisorFormState();
}

// ── AI advice result provider ─────────────────────────────────────────
// Starts as null (no advice yet). Set when user taps "Analyze with AI".
final aiAdviceProvider =
    StateNotifierProvider<AIAdviceNotifier, AsyncValue<AIAdvice?>>(
  (ref) => AIAdviceNotifier(ref),
);

class AIAdviceNotifier extends StateNotifier<AsyncValue<AIAdvice?>> {
  final Ref _ref;

  AIAdviceNotifier(this._ref) : super(const AsyncValue.data(null));

  // Called when user taps "Analyze with AI" button.
  // Always hits the API — skipping cache so every input change produces fresh advice.
  Future<void> analyze() async {
    final form = _ref.read(advisorFormProvider);
    final api  = _ref.read(apiServiceProvider);

    state = const AsyncValue.loading();

    try {
      final request = AIAdviceRequest(
        district:        form.district,
        crop:            form.crop,
        province:        form.province,
        season:          form.season,
        farmSizeAcres:   form.farmSizeAcres,
        ndvi:            form.ndvi,
        rainfallMm:      form.rainfallMm,
        tempMaxC:        form.tempMaxC,
        soilMoisturePct: form.soilMoisturePct,
        waterTableM:     form.waterTableM,
        symptoms:        form.selectedSymptoms,
      );

      final advice = await api.getAIAdvice(request: request);
      state = AsyncValue.data(advice);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearAdvice() => state = const AsyncValue.data(null);
}

