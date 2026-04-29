// lib/data/models/stats_model.dart
//
// StatsModel — complete statistical analysis results for one district/crop.
// Contains descriptive stats, trend analysis, and ML model performance metrics.
// Used by: Analytics screen (all 6 charts), Stats API endpoint.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_model.freezed.dart';
part 'stats_model.g.dart';

// ─────────────────────────────────────────────────────────────────────────
// TREND DIRECTION ENUM
// Whether yields are improving, declining, or stable over the data period.
// ─────────────────────────────────────────────────────────────────────────
enum TrendDirection {
  @JsonValue('improving')  improving,
  @JsonValue('stable')     stable,
  @JsonValue('declining')  declining,
}

extension TrendDirectionLabel on TrendDirection {
  String get label {
    switch (this) {
      case TrendDirection.improving: return '↑ Improving';
      case TrendDirection.stable:    return '→ Stable';
      case TrendDirection.declining: return '↓ Declining';
    }
  }
}

@freezed
class StatsModel with _$StatsModel {
  const factory StatsModel({
    required String district,
    required String crop,

    // ── Descriptive Statistics ────────────────────────────────────
    // All yield values are in tonnes/acre
    required double mean,      // Average yield over all years
    required double median,    // Middle value (less affected by outliers)
    required double std,       // Standard deviation (spread of data)
    required double min,       // Lowest recorded yield
    required double max,       // Highest recorded yield
    required double q1,        // 25th percentile
    required double q3,        // 75th percentile

    // ── Trend Analysis ────────────────────────────────────────────
    required TrendDirection trendDirection,

    // Linear trend slope: tonnes/acre increase per year (can be negative)
    required double trendSlope,

    // ── Hypothesis Testing (t-test: is yield significantly above threshold?) ─
    // p-value from one-sample t-test (< 0.05 means statistically significant)
    required double pValue,

    // ── Regression Model Performance ──────────────────────────────
    // R² score: 0.0 = model explains nothing, 1.0 = perfect prediction
    required double rSquared,

    // RMSE: Root Mean Squared Error in tonnes/acre (lower = better)
    required double rmse,

    // ── Drought Probability ────────────────────────────────────────
    // Probability that yield falls below drought threshold (0.0–1.0)
    @Default(0.0) double droughtProbability,

    // Drought threshold yield in tonnes/acre (below this = drought)
    @Default(1.0) double droughtThreshold,

    // ── Sample Info ───────────────────────────────────────────────
    // Number of years of data used in analysis
    @Default(19) int sampleSize,

    // Year range: "2005–2023"
    @Default('2005–2023') String yearRange,
  }) = _StatsModel;

  factory StatsModel.fromJson(Map<String, dynamic> json) =>
      _$StatsModelFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────
// StatsResponse — wraps stats for multiple crops in one district
// The API returns stats for all 5 crops at once to reduce HTTP calls.
// ─────────────────────────────────────────────────────────────────────────
@freezed
class StatsResponse with _$StatsResponse {
  const factory StatsResponse({
    required String district,
    // Key = crop id (e.g., "wheat"), Value = stats for that crop
    required Map<String, StatsModel> byCrop,
  }) = _StatsResponse;

  factory StatsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatsResponseFromJson(json);
}