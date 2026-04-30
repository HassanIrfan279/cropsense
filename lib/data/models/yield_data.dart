// lib/data/models/yield_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'yield_data.freezed.dart';
part 'yield_data.g.dart';

@freezed
class YieldData with _$YieldData {
  const factory YieldData({
    required String district,
    required String crop,
    required int year,
    int? month,
    required double yieldTAcre,
    required double ndvi,
    required double rainfallMm,
    required double tempMaxC,
    required double tempMinC,
    required double soilMoisturePct,
    double? predictedYield,
  }) = _YieldData;

  factory YieldData.fromJson(Map<String, dynamic> json) =>
      _$YieldDataFromJson(json);
}

@freezed
class YieldDataResponse with _$YieldDataResponse {
  const factory YieldDataResponse({
    required String district,
    required String crop,
    required List<YieldData> data,
  }) = _YieldDataResponse;

  factory YieldDataResponse.fromJson(Map<String, dynamic> json) =>
      _$YieldDataResponseFromJson(json);
}