// lib/data/models/medicine.dart
//
// Medicine — a specific product recommended by the AI Advisor.
// Contains real Pakistani market brand names, doses in per-acre units,
// prices in PKR, and urgency level.
// Used by: AI Advisor screen → MedicineCard widget.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine.freezed.dart';
part 'medicine.g.dart';

// ─────────────────────────────────────────────────────────────────────────
// URGENCY ENUM
// How soon the farmer needs to apply this treatment.
// ─────────────────────────────────────────────────────────────────────────
enum MedicineUrgency {
  @JsonValue('immediate')    immediate,    // Apply today — disease is spreading
  @JsonValue('within_week')  withinWeek,   // Apply within 7 days
  @JsonValue('preventive')   preventive,   // Apply as prevention, no active disease
}

extension MedicineUrgencyLabel on MedicineUrgency {
  String get label {
    switch (this) {
      case MedicineUrgency.immediate:   return 'Apply Immediately';
      case MedicineUrgency.withinWeek:  return 'Apply Within a Week';
      case MedicineUrgency.preventive:  return 'Preventive Application';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MEDICINE TYPE ENUM
// Categorizes the product so the UI can show an appropriate icon.
// ─────────────────────────────────────────────────────────────────────────
enum MedicineType {
  @JsonValue('fungicide')   fungicide,    // Treats fungal diseases (rust, blight)
  @JsonValue('pesticide')   pesticide,    // Treats insect pests
  @JsonValue('herbicide')   herbicide,    // Treats weeds
  @JsonValue('fertilizer')  fertilizer,   // Nutrient supplement
  @JsonValue('growth_reg')  growthReg,    // Growth regulator
}

extension MedicineTypeLabel on MedicineType {
  String get label {
    switch (this) {
      case MedicineType.fungicide:  return 'Fungicide';
      case MedicineType.pesticide:  return 'Pesticide';
      case MedicineType.herbicide:  return 'Herbicide';
      case MedicineType.fertilizer: return 'Fertilizer';
      case MedicineType.growthReg:  return 'Growth Regulator';
    }
  }
}

@freezed
class Medicine with _$Medicine {
  const factory Medicine({
    // Brand name sold in Pakistani markets: e.g., "Topsin-M 70 WP"
    required String name,

    // Category: fungicide / pesticide / herbicide / fertilizer / growth_reg
    required MedicineType type,

    // Chemical/active ingredient: e.g., "Thiophanate-methyl 70%"
    required String activeIngredient,

    // Application dose per acre: e.g., "250g per acre" or "500ml per acre"
    required String dose,

    // Estimated price per acre in Pakistani Rupees
    required double pricePerAcrePkr,

    // How urgently this needs to be applied
    required MedicineUrgency urgency,

    // What disease/problem this treats: e.g., "Wheat rust (Puccinia striiformis)"
    required String purpose,

    // Where to buy in Pakistan: e.g., "Any agri store in Faisalabad grain market"
    required String whereToBuy,

    // Optional note: mixing instructions, safety warnings, etc.
    String? applicationNote,
  }) = _Medicine;

  factory Medicine.fromJson(Map<String, dynamic> json) =>
      _$MedicineFromJson(json);
}