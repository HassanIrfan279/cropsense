// lib/data/models/risk_map.dart
//
// RiskMapEntry — risk level and crop yields for one district on the map.
// RiskMapResponse — wraps a list of all 36 district entries.
// Used by: Map screen (polygon coloring), Dashboard (alert ticker).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'risk_map.freezed.dart';
part 'risk_map.g.dart';

// ─────────────────────────────────────────────────────────────────────────
// RISK LEVEL ENUM
// Typed risk levels prevent typos like "hgih" instead of "high".
// The @JsonValue annotations tell JSON serialization what string to expect.
// ─────────────────────────────────────────────────────────────────────────
enum RiskLevel {
  @JsonValue('good')     good,
  @JsonValue('above')    above,
  @JsonValue('watch')    watch,
  @JsonValue('high')     high,
  @JsonValue('critical') critical,
}

// Helper: convert RiskLevel enum to display string
extension RiskLevelLabel on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.good:     return 'Good';
      case RiskLevel.above:    return 'Above Average';
      case RiskLevel.watch:    return 'Watch';
      case RiskLevel.high:     return 'High Risk';
      case RiskLevel.critical: return 'Critical';
    }
  }

  // Returns the hex color string for this risk level
  String get colorHex {
    switch (this) {
      case RiskLevel.good:     return '#1B5E20';
      case RiskLevel.above:    return '#8BC34A';
      case RiskLevel.watch:    return '#FF8F00';
      case RiskLevel.high:     return '#E65100';
      case RiskLevel.critical: return '#B71C1C';
    }
  }
}

@freezed
class RiskMapEntry with _$RiskMapEntry {
  const factory RiskMapEntry({
    // District identifier: e.g., "faisalabad"
    required String district,

    // Human-readable district name
    required String districtName,

    // Province name
    required String province,

    // Typed risk level enum (good/above/watch/high/critical)
    required RiskLevel riskLevel,

    // Numeric risk score 0–100 (used for risk meter gauge)
    required double riskScore,

    // Yield forecasts per crop: { "wheat": 2.3, "rice": 1.8, ... }
    // Using Map<String, double> because crops may vary by district
    @Default({}) Map<String, double> cropYields,

    // Current NDVI for quick display on map tooltip
    @Default(0.0) double ndvi,

    // Number of active alerts for this district
    @Default(0) int alertCount,
  }) = _RiskMapEntry;

  factory RiskMapEntry.fromJson(Map<String, dynamic> json) =>
      _$RiskMapEntryFromJson(json);
}

// The full risk map response from GET /api/risk-map
@freezed
class RiskMapResponse with _$RiskMapResponse {
  const factory RiskMapResponse({
    // All 36 district entries
    required List<RiskMapEntry> districts,

    // When this risk map was generated on the backend
    required String generatedAt,

    // Overall Pakistan risk summary
    @Default('good') String nationalRiskLevel,
    @Default(0) int criticalCount,
    @Default(0) int highCount,
    @Default(0) int watchCount,
  }) = _RiskMapResponse;

  factory RiskMapResponse.fromJson(Map<String, dynamic> json) =>
      _$RiskMapResponseFromJson(json);
}