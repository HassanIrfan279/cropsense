// lib/providers/ai_advisor_provider.dart
//
// Manages the AI Advisor screen:
//   - Form field values (crop, district, NDVI sliders, symptoms)
//   - The async AI advice API call
//   - The result displayed in the right panel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';
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

  void setDistrict(String v)        => state = state.copyWith(district: v);
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

  // Called when user taps "Analyze with AI" button
  Future<void> analyze() async {
    final form  = _ref.read(advisorFormProvider);
    final api   = _ref.read(apiServiceProvider);
    final cache = _ref.read(cacheServiceProvider);

    // Show loading spinner in the result panel
    state = const AsyncValue.loading();

    try {
      // Check cache first — 6 hour freshness for AI advice
      final cached = cache.getCachedAIAdvice(form.district, form.crop);
      if (cached != null) {
        state = AsyncValue.data(AIAdvice.fromJson(cached));
        return;
      }

      // Build the request object from current form state
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

      // Cache the result
      await cache.cacheAIAdvice(form.district, form.crop, advice.toJson());

      state = AsyncValue.data(advice);
    } catch (e, st) {
      // Show mock advice when backend isn't running yet
      state = AsyncValue.data(_mockAdvice(form.district, form.crop));
    }
  }

  void clearAdvice() => state = const AsyncValue.data(null);
}

// Mock AI advice for offline development / UI testing
AIAdvice _mockAdvice(String district, String crop) {
  return AIAdvice(
    alertUrdu: 'Fasal ko zang ka khatara hai — kal subah spray karein',
    alertEnglish:
        'Wheat rust risk detected — immediate fungicide application recommended',
    diagnosis: 'Yellow rust (Puccinia striiformis) — Early Stage',
    confidencePct: 87.0,
    actionSteps: [
      '1. Apply Topsin-M 70 WP at 250g per acre within 48 hours',
      '2. Increase irrigation frequency to every 8 days',
      '3. Avoid nitrogen fertilizer for the next 2 weeks',
      '4. Monitor leaves daily — if spreading, repeat spray after 10 days',
      '5. Report to local agriculture office if more than 30% leaves affected',
    ],
    medicines: [],
    fertilizerAdvice:
        'Hold all nitrogen (urea) applications for 2 weeks. '
        'Apply 1 bag DAP per acre after disease is controlled.',
    irrigationAdvice:
        'Increase to every 8 days. Avoid waterlogging — '
        'ensure field has proper drainage channels open.',
    totalCostPerAcrePkr: 12500,
    totalCostForFarmPkr: 62500,
    expectedYieldIncreasePct: 18.0,
    roiNote:
        'Spending ₨12,500 now protects an estimated ₨45,000 worth of yield. '
        'Net ROI: 260% on treatment cost.',
    nextCheckupDays: 7,
    generatedAt: DateTime.now().toIso8601String(),
    district: district,
    crop: crop,
  );
}