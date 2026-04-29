// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicineImpl _$$MedicineImplFromJson(Map<String, dynamic> json) =>
    _$MedicineImpl(
      name: json['name'] as String,
      type: $enumDecode(_$MedicineTypeEnumMap, json['type']),
      activeIngredient: json['activeIngredient'] as String,
      dose: json['dose'] as String,
      pricePerAcrePkr: (json['pricePerAcrePkr'] as num).toDouble(),
      urgency: $enumDecode(_$MedicineUrgencyEnumMap, json['urgency']),
      purpose: json['purpose'] as String,
      whereToBuy: json['whereToBuy'] as String,
      applicationNote: json['applicationNote'] as String?,
    );

Map<String, dynamic> _$$MedicineImplToJson(_$MedicineImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$MedicineTypeEnumMap[instance.type]!,
      'activeIngredient': instance.activeIngredient,
      'dose': instance.dose,
      'pricePerAcrePkr': instance.pricePerAcrePkr,
      'urgency': _$MedicineUrgencyEnumMap[instance.urgency]!,
      'purpose': instance.purpose,
      'whereToBuy': instance.whereToBuy,
      'applicationNote': instance.applicationNote,
    };

const _$MedicineTypeEnumMap = {
  MedicineType.fungicide: 'fungicide',
  MedicineType.pesticide: 'pesticide',
  MedicineType.herbicide: 'herbicide',
  MedicineType.fertilizer: 'fertilizer',
  MedicineType.growthReg: 'growth_reg',
};

const _$MedicineUrgencyEnumMap = {
  MedicineUrgency.immediate: 'immediate',
  MedicineUrgency.withinWeek: 'within_week',
  MedicineUrgency.preventive: 'preventive',
};
