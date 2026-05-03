// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComparisonModelImpl _$$ComparisonModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ComparisonModelImpl(
      crop: json['crop'] as String,
      district1Stats: json['district1Stats'] as Map<String, dynamic>,
      district2Stats: json['district2Stats'] as Map<String, dynamic>,
      seriesCorrelation: json['seriesCorrelation'] as Map<String, dynamic>,
      mannWhitney: json['mannWhitney'] as Map<String, dynamic>,
      exceedanceProb2t: json['exceedanceProb2t'] as Map<String, dynamic>,
      betterDistrict: json['betterDistrict'] as String,
      percentageDiffs: json['percentageDiffs'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$ComparisonModelImplToJson(
        _$ComparisonModelImpl instance) =>
    <String, dynamic>{
      'crop': instance.crop,
      'district1Stats': instance.district1Stats,
      'district2Stats': instance.district2Stats,
      'seriesCorrelation': instance.seriesCorrelation,
      'mannWhitney': instance.mannWhitney,
      'exceedanceProb2t': instance.exceedanceProb2t,
      'betterDistrict': instance.betterDistrict,
      'percentageDiffs': instance.percentageDiffs,
    };
