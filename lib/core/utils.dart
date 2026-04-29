// lib/core/utils.dart
//
// CropSense Utility Functions
// ─────────────────────────────────────────────────────────────────────────
// Pure helper functions — no Flutter widgets, no state.
// Import with: import 'package:cropsense/core/utils.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cropsense/core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────
// PKR CURRENCY FORMATTER
// Formats a double as Pakistani Rupee with commas and ₨ symbol.
// Example: formatPKR(125000.0) → "₨ 1,25,000"
// Pakistan uses the South Asian numbering system (lakh/crore grouping).
// ─────────────────────────────────────────────────────────────────────────
String formatPKR(double amount, {bool compact = false}) {
  if (compact) {
    // For large numbers: show "₨ 1.2L" (lakh) or "₨ 3.4Cr" (crore)
    if (amount >= 10000000) {
      return '₨ ${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₨ ${(amount / 100000).toStringAsFixed(1)}L';
    }
  }
  final formatter = NumberFormat('#,##,###', 'en_IN'); // Indian grouping = Pakistani
  return '₨ ${formatter.format(amount.round())}';
}

// ─────────────────────────────────────────────────────────────────────────
// YIELD FORMATTER
// Formats yield tonnes per acre with 2 decimal places.
// Example: formatYield(2.1453) → "2.15 t/acre"
// ─────────────────────────────────────────────────────────────────────────
String formatYield(double value) {
  return '${value.toStringAsFixed(2)} t/acre';
}

// ─────────────────────────────────────────────────────────────────────────
// NDVI FORMATTER
// NDVI (Normalized Difference Vegetation Index) is 0.0–1.0.
// Example: formatNdvi(0.682) → "0.68"
// ─────────────────────────────────────────────────────────────────────────
String formatNdvi(double value) {
  return value.toStringAsFixed(2);
}

// ─────────────────────────────────────────────────────────────────────────
// PERCENTAGE FORMATTER
// Example: formatPercent(73.5) → "73.5%"
// ─────────────────────────────────────────────────────────────────────────
String formatPercent(double value, {int decimals = 1}) {
  return '${value.toStringAsFixed(decimals)}%';
}

// ─────────────────────────────────────────────────────────────────────────
// RISK LEVEL → COLOR
// Maps a risk level string to the correct AppColors color.
// Used by the map polygons, risk badges, and risk meter.
// ─────────────────────────────────────────────────────────────────────────
Color riskColor(String riskLevel) {
  switch (riskLevel.toLowerCase()) {
    case 'good':
      return AppColors.riskGood;
    case 'above':
    case 'above_average':
      return AppColors.riskAbove;
    case 'watch':
      return AppColors.riskWatch;
    case 'high':
      return AppColors.riskHigh;
    case 'critical':
      return AppColors.riskCritical;
    default:
      return AppColors.grey400;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// RISK SCORE → COLOR (numeric version, 0–100)
// For the RiskMeter gauge widget.
// ─────────────────────────────────────────────────────────────────────────
Color riskScoreColor(double score) {
  if (score < 20) return AppColors.riskGood;
  if (score < 40) return AppColors.riskAbove;
  if (score < 60) return AppColors.riskWatch;
  if (score < 80) return AppColors.riskHigh;
  return AppColors.riskCritical;
}

// ─────────────────────────────────────────────────────────────────────────
// RISK LEVEL → LABEL (human-readable)
// ─────────────────────────────────────────────────────────────────────────
String riskLabel(String riskLevel) {
  switch (riskLevel.toLowerCase()) {
    case 'good':        return 'Good';
    case 'above':       return 'Above Average';
    case 'watch':       return 'Watch';
    case 'high':        return 'High Risk';
    case 'critical':    return 'Critical';
    default:            return 'Unknown';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PROVINCE → CROP COLORS
// Returns the color for a given crop index (0–4).
// ─────────────────────────────────────────────────────────────────────────
Color cropColor(int index) {
  const colors = AppColors.cropColors;
  return colors[index % colors.length];
}

// ─────────────────────────────────────────────────────────────────────────
// DATE FORMATTER
// Formats a DateTime for display in the UI.
// ─────────────────────────────────────────────────────────────────────────
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('MMM yyyy').format(date);
}

// ─────────────────────────────────────────────────────────────────────────
// CONFIDENCE INTERVAL LABEL
// Displays a CI range in the "2.0 – 2.4 t/acre" style.
// ─────────────────────────────────────────────────────────────────────────
String formatCI(double low, double high) {
  return '${low.toStringAsFixed(1)} – ${high.toStringAsFixed(1)} t/acre';
}

// ─────────────────────────────────────────────────────────────────────────
// SCREEN SIZE HELPERS
// Quick checks for adaptive layout decisions.
// ─────────────────────────────────────────────────────────────────────────
bool isCompact(BuildContext context) {
  return MediaQuery.of(context).size.width < 800.0;
}

bool isWide(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1200.0;
}

bool isStandard(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= 800.0 && width < 1200.0;
}