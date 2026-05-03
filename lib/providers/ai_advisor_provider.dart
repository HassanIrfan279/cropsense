import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:cropsense/app.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/data/models/ai_advice.dart';
import 'package:cropsense/data/models/chat_message.dart';
import 'package:cropsense/providers/field_management_provider.dart';
import 'package:cropsense/providers/weather_provider.dart';

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
  final String soilType;
  final double farmSizeAcres;
  final double budgetPkr;
  final double ndvi;
  final double rainfallMm;
  final double tempMaxC;
  final double soilMoisturePct;
  final double waterTableM;
  final List<String> selectedSymptoms;
  final bool weatherAutoFilled;

  const AdvisorFormState({
    this.district = 'faisalabad',
    this.crop = 'wheat',
    this.province = 'Punjab',
    this.season = 'Rabi',
    this.soilType = 'loam',
    this.farmSizeAcres = 5.0,
    this.budgetPkr = 150000.0,
    this.ndvi = 0.5,
    this.rainfallMm = 150.0,
    this.tempMaxC = 35.0,
    this.soilMoisturePct = 40.0,
    this.waterTableM = 8.0,
    this.selectedSymptoms = const [],
    this.weatherAutoFilled = false,
  });

  // Creates a copy with some fields changed — same pattern as Freezed
  AdvisorFormState copyWith({
    String? district,
    String? crop,
    String? province,
    String? season,
    String? soilType,
    double? farmSizeAcres,
    double? budgetPkr,
    double? ndvi,
    double? rainfallMm,
    double? tempMaxC,
    double? soilMoisturePct,
    double? waterTableM,
    List<String>? selectedSymptoms,
    bool? weatherAutoFilled,
  }) {
    return AdvisorFormState(
      district: district ?? this.district,
      crop: crop ?? this.crop,
      province: province ?? this.province,
      season: season ?? this.season,
      soilType: soilType ?? this.soilType,
      farmSizeAcres: farmSizeAcres ?? this.farmSizeAcres,
      budgetPkr: budgetPkr ?? this.budgetPkr,
      ndvi: ndvi ?? this.ndvi,
      rainfallMm: rainfallMm ?? this.rainfallMm,
      tempMaxC: tempMaxC ?? this.tempMaxC,
      soilMoisturePct: soilMoisturePct ?? this.soilMoisturePct,
      waterTableM: waterTableM ?? this.waterTableM,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      weatherAutoFilled: weatherAutoFilled ?? this.weatherAutoFilled,
    );
  }
}

// ── Form state provider ───────────────────────────────────────────────
final advisorFormProvider =
    StateNotifierProvider<AdvisorFormNotifier, AdvisorFormState>(
  (ref) => AdvisorFormNotifier(ref),
);

class AdvisorFormNotifier extends StateNotifier<AdvisorFormState> {
  final Ref _ref;
  AdvisorFormNotifier(this._ref) : super(const AdvisorFormState());

  void setDistrict(String v) {
    final match = AppDistricts.all.firstWhere(
      (d) => d['id'] == v,
      orElse: () => {'id': v, 'label': v, 'province': 'Punjab'},
    );
    state = state.copyWith(
      district: v,
      province: match['province'],
      weatherAutoFilled: false,
    );
    _autoFillWeather(v);
  }

  Future<void> _autoFillWeather(String district) async {
    try {
      final weather = await _ref.read(weatherProvider(district).future);
      state = state.copyWith(
        rainfallMm: weather.rainfall30day.clamp(0.0, 500.0),
        tempMaxC: weather.tempMaxForecast.clamp(0.0, 55.0),
        ndvi: weather.ndviEstimate.clamp(0.0, 1.0),
        weatherAutoFilled: true,
      );
    } catch (_) {
      // silently ignore — user can set manually
    }
  }

  void setCrop(String v) => state = state.copyWith(crop: v);
  void setProvince(String v) => state = state.copyWith(province: v);
  void setSeason(String v) => state = state.copyWith(season: v);
  void setSoilType(String v) => state = state.copyWith(soilType: v);
  void setFarmSize(double v) => state = state.copyWith(farmSizeAcres: v);
  void setBudget(double v) => state = state.copyWith(budgetPkr: v);
  void setNdvi(double v) => state = state.copyWith(ndvi: v);
  void setRainfall(double v) => state = state.copyWith(rainfallMm: v);
  void setTempMax(double v) => state = state.copyWith(tempMaxC: v);
  void setSoilMoisture(double v) => state = state.copyWith(soilMoisturePct: v);
  void setWaterTable(double v) => state = state.copyWith(waterTableM: v);

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

  void clearSymptoms() => state = state.copyWith(selectedSymptoms: []);

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
    final api = _ref.read(apiServiceProvider);

    state = const AsyncValue.loading();

    try {
      final request = AIAdviceRequest(
        district: form.district,
        crop: form.crop,
        province: form.province,
        season: form.season,
        farmSizeAcres: form.farmSizeAcres,
        ndvi: form.ndvi,
        rainfallMm: form.rainfallMm,
        tempMaxC: form.tempMaxC,
        soilMoisturePct: form.soilMoisturePct,
        waterTableM: form.waterTableM,
        symptoms: form.selectedSymptoms,
      );

      final advice = await api.getAIAdvice(request: request);
      state = AsyncValue.data(advice);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearAdvice() => state = const AsyncValue.data(null);
}

// ── Chat provider ─────────────────────────────────────────────────────────────

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(ref),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  static const _uuid = Uuid();

  ChatNotifier(this._ref) : super([_welcomeMessage()]);

  Future<void> sendMessage(String text) async {
    _addUserMsg(text);
    final lid = _addLoading();
    try {
      final form = _ref.read(advisorFormProvider);
      final fieldState = _ref.read(fieldManagementProvider);
      final fieldData = <String, dynamic>{};
      if (fieldState.selectedField != null) {
        fieldData['selectedField'] = fieldState.selectedField;
      }
      if (fieldState.analytics != null) {
        fieldData['selectedFieldAnalytics'] = fieldState.analytics;
      }
      final history =
          state.where((m) => !m.isLoading).map((m) => m.toJson()).toList();
      final result = await _ref.read(apiServiceProvider).sendChatMessage(
        messages: history,
        district: form.district,
        crop: form.crop,
        context: {
          'ndvi': form.ndvi,
          'rainfallMm': form.rainfallMm,
          'tempMaxC': form.tempMaxC,
          'soilMoisturePct': form.soilMoisturePct,
          'waterTableM': form.waterTableM,
          'province': form.province,
          'season': form.season,
          'soilType': form.soilType,
          'farmSizeAcres': form.farmSizeAcres,
          'budgetPkr': form.budgetPkr,
          'startYear': DataConstants.startYear,
          'endYear': DataConstants.endYear,
          'selectedYear': DataConstants.endYear,
          'symptoms': form.selectedSymptoms,
          if (fieldData.isNotEmpty) 'fieldData': fieldData,
        },
      );
      _resolve(
          lid,
          ChatMessage(
            id: _uuid.v4(),
            role: 'assistant',
            content: result['reply'] as String? ?? '',
            directAnswer: result['directAnswer'] as String?,
            explanation: result['explanation'] as String?,
            recommendation: result['recommendation'] as String?,
            confidenceLevel: result['confidenceLevel'] as String?,
            warning: result['warning'] as String?,
            contentUrdu: result['replyUrdu'] as String?,
            timestamp: DateTime.now(),
            suggestions: _stringList(result['suggestions']),
            dataUsed: _stringList(result['dataUsed']),
            risksWarnings: _stringList(result['risksWarnings']),
            nextSteps: _stringList(result['nextSteps']),
            sourceLabels: _stringList(result['sourceLabels']),
            isError: result['status'] == 'fallback' &&
                (result['warning'] as String? ?? '').isNotEmpty,
          ));
    } catch (_) {
      _resolve(lid, _errMsg());
    }
  }

  Future<void> analyzeImage(String base64) async {
    final form = _ref.read(advisorFormProvider);
    _addUserMsg('Analyze this crop image', imageBase64: base64);
    final lid = _addLoading();
    try {
      final result = await _ref.read(apiServiceProvider).analyzeCropImage(
            imageBase64: base64,
            district: form.district,
            crop: form.crop,
          );
      final disease = result['disease'] as String? ?? 'Unknown';
      final severity = result['severity'] as String? ?? 'Unknown';
      final pct = (result['affectedPct'] as num?)?.toDouble() ?? 0.0;
      final desc = result['description'] as String? ?? '';
      final treat = result['treatment'] as String? ?? '';
      final content =
          '$disease — $severity severity (${pct.toStringAsFixed(0)}% affected)\n$desc\nTreatment: $treat';
      _resolve(
          lid,
          ChatMessage(
            id: _uuid.v4(),
            role: 'assistant',
            content: content,
            contentUrdu: result['urduSummary'] as String?,
            timestamp: DateTime.now(),
            suggestions:
                List<String>.from(result['suggestions'] as List? ?? []),
            imageAnalysis: result,
          ));
    } catch (_) {
      _resolve(lid, _errMsg());
    }
  }

  void clearChat() => state = [_welcomeMessage()];

  // ── helpers ──────────────────────────────────────────────────────────────
  void _addUserMsg(String text, {String? imageBase64}) {
    state = [
      ...state,
      ChatMessage(
        id: _uuid.v4(),
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
        imageBase64: imageBase64,
      ),
    ];
  }

  String _addLoading() {
    final id = _uuid.v4();
    state = [
      ...state,
      ChatMessage(
          id: id,
          role: 'assistant',
          content: '',
          timestamp: DateTime.now(),
          isLoading: true),
    ];
    return id;
  }

  void _resolve(String lid, ChatMessage msg) {
    state = state.map((m) => m.id == lid ? msg : m).toList();
  }

  ChatMessage _errMsg() => ChatMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content:
            'Sorry, I could not get a response. Please check your connection and try again.',
        directAnswer:
            'I could not reach the farming assistant service from this device.',
        explanation:
            'The backend may be offline, the network may be unavailable, or the request timed out.',
        recommendation:
            'Start the backend and try again with the same question.',
        risksWarnings: const [
          'No fresh answer was generated for this message.',
        ],
        nextSteps: const [
          'Check that FastAPI is running.',
          'Confirm your API base URL points to the backend.',
          'Send the question again.',
        ],
        confidenceLevel: 'low',
        sourceLabels: const ['Connection error'],
        isError: true,
        timestamp: DateTime.now(),
      );
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value];
  }
  return const [];
}

ChatMessage _welcomeMessage() => ChatMessage(
      id: 'welcome',
      role: 'assistant',
      content:
          'Assalam-o-Alaikum! I am your AI Farm Assistant powered by Grok. '
          'Ask about crop choice, profit, fertilizer, irrigation, weather risk, soil, pests, or your analytics report.',
      directAnswer:
          'Tell me your farming question and I will use your profile plus CropSense 2005-2023 analytics where available.',
      explanation:
          'I will say clearly when data is historical, demo, missing, or uncertain.',
      contentUrdu:
          'Main aapka AI Ziraat Mashwara hun. Bimari, khaad, aabpashi ke baare mein poochein ya photo bhejein.',
      timestamp: DateTime.now(),
      sourceLabels: const [
        'Based on selected farm profile',
        'Uses 2005-2023 analytics'
      ],
      suggestions: [
        'Which crop is best for me?',
        'How much profit can I expect?',
        'What risks should I avoid?',
        'Generate my crop plan',
      ],
    );
