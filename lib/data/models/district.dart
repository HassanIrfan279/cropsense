// lib/data/models/district.dart
//
// District model — represents one of Pakistan's 36 agricultural districts.
// Every map polygon, KPI card, and AI advisory is linked to a District object.
//
// The @freezed annotation tells build_runner to generate:
//   district.freezed.dart — immutable class with copyWith, ==, hashCode
//   district.g.dart       — fromJson / toJson methods

import 'package:freezed_annotation/freezed_annotation.dart';

// These two lines connect this file to its generated counterparts.
// build_runner will create these files — don't worry that they don't exist yet.
part 'district.freezed.dart';
part 'district.g.dart';

@freezed
class District with _$District {
  const factory District({
    // Unique identifier used in API calls: e.g., "faisalabad"
    required String id,

    // Human-readable name: e.g., "Faisalabad"
    required String name,

    // Province this district belongs to: e.g., "Punjab"
    required String province,

    // Geographic center coordinates (used to position map markers)
    required double lat,
    required double lng,

    // Risk score from 0 (perfect) to 100 (critical drought/disease)
    @Default(0.0) double riskScore,

    // Risk level as a string: good / above / watch / high / critical
    @Default('good') String riskLevel,

    // Current NDVI reading (0.0 = bare soil, 1.0 = dense healthy vegetation)
    @Default(0.0) double currentNdvi,

    // Predicted yield for the next 14 days in tonnes/acre
    @Default(0.0) double currentYieldForecast,

    // Confidence interval lower bound (statistical uncertainty range)
    @Default(0.0) double confidenceLow,

    // Confidence interval upper bound
    @Default(0.0) double confidenceHigh,

    // Which crop this forecast is for (default: wheat)
    @Default('wheat') String forecastCrop,

    // When this data was last updated (ISO 8601 string from backend)
    String? lastUpdated,
  }) = _District;

  // This factory constructor reads a JSON map and returns a District object.
  // build_runner generates the actual implementation in district.g.dart.
  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(json);
}