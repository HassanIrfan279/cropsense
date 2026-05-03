// lib/data/models/ai_advice.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cropsense/data/models/medicine.dart';

part 'ai_advice.freezed.dart';
part 'ai_advice.g.dart';

@freezed
class AIAdvice with _$AIAdvice {
  const factory AIAdvice({
    required String alertUrdu,
    required String alertEnglish,
    required String diagnosis,
    required double confidencePct,
    required List<String> actionSteps,
    required List<Medicine> medicines,
    required String fertilizerAdvice,
    required String irrigationAdvice,
    required double totalCostPerAcrePkr,
    required double totalCostForFarmPkr,
    required double expectedYieldIncreasePct,
    required String roiNote,
    required int nextCheckupDays,
    String? generatedAt,
    String? district,
    String? crop,
  }) = _AIAdvice;

  factory AIAdvice.fromJson(Map<String, dynamic> json) =>
      _$AIAdviceFromJson(json);
}

@freezed
class AIAdviceRequest with _$AIAdviceRequest {
  const factory AIAdviceRequest({
    required String district,
    required String crop,
    required String province,
    required String season,
    required double farmSizeAcres,
    required double ndvi,
    required double rainfallMm,
    required double tempMaxC,
    required double soilMoisturePct,
    required double waterTableM,
    required List<String> symptoms,
    @Default('en') String language,
  }) = _AIAdviceRequest;

  factory AIAdviceRequest.fromJson(Map<String, dynamic> json) =>
      _$AIAdviceRequestFromJson(json);
}
