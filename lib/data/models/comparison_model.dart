import 'package:freezed_annotation/freezed_annotation.dart';

part 'comparison_model.freezed.dart';
part 'comparison_model.g.dart';

@freezed
class ComparisonModel with _$ComparisonModel {
  const factory ComparisonModel({
    required String crop,
    required Map<String, dynamic> district1Stats,
    required Map<String, dynamic> district2Stats,
    required Map<String, dynamic> seriesCorrelation,
    required Map<String, dynamic> mannWhitney,
    required Map<String, dynamic> exceedanceProb2t,
    required String betterDistrict,
    required Map<String, dynamic> percentageDiffs,
  }) = _ComparisonModel;

  factory ComparisonModel.fromJson(Map<String, dynamic> json) =>
      _$ComparisonModelFromJson(json);
}
