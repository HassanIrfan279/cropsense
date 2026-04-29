// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'district.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

District _$DistrictFromJson(Map<String, dynamic> json) {
  return _District.fromJson(json);
}

/// @nodoc
mixin _$District {
// Unique identifier used in API calls: e.g., "faisalabad"
  String get id =>
      throw _privateConstructorUsedError; // Human-readable name: e.g., "Faisalabad"
  String get name =>
      throw _privateConstructorUsedError; // Province this district belongs to: e.g., "Punjab"
  String get province =>
      throw _privateConstructorUsedError; // Geographic center coordinates (used to position map markers)
  double get lat => throw _privateConstructorUsedError;
  double get lng =>
      throw _privateConstructorUsedError; // Risk score from 0 (perfect) to 100 (critical drought/disease)
  double get riskScore =>
      throw _privateConstructorUsedError; // Risk level as a string: good / above / watch / high / critical
  String get riskLevel =>
      throw _privateConstructorUsedError; // Current NDVI reading (0.0 = bare soil, 1.0 = dense healthy vegetation)
  double get currentNdvi =>
      throw _privateConstructorUsedError; // Predicted yield for the next 14 days in tonnes/acre
  double get currentYieldForecast =>
      throw _privateConstructorUsedError; // Confidence interval lower bound (statistical uncertainty range)
  double get confidenceLow =>
      throw _privateConstructorUsedError; // Confidence interval upper bound
  double get confidenceHigh =>
      throw _privateConstructorUsedError; // Which crop this forecast is for (default: wheat)
  String get forecastCrop =>
      throw _privateConstructorUsedError; // When this data was last updated (ISO 8601 string from backend)
  String? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DistrictCopyWith<District> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DistrictCopyWith<$Res> {
  factory $DistrictCopyWith(District value, $Res Function(District) then) =
      _$DistrictCopyWithImpl<$Res, District>;
  @useResult
  $Res call(
      {String id,
      String name,
      String province,
      double lat,
      double lng,
      double riskScore,
      String riskLevel,
      double currentNdvi,
      double currentYieldForecast,
      double confidenceLow,
      double confidenceHigh,
      String forecastCrop,
      String? lastUpdated});
}

/// @nodoc
class _$DistrictCopyWithImpl<$Res, $Val extends District>
    implements $DistrictCopyWith<$Res> {
  _$DistrictCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? province = null,
    Object? lat = null,
    Object? lng = null,
    Object? riskScore = null,
    Object? riskLevel = null,
    Object? currentNdvi = null,
    Object? currentYieldForecast = null,
    Object? confidenceLow = null,
    Object? confidenceHigh = null,
    Object? forecastCrop = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      province: null == province
          ? _value.province
          : province // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      currentNdvi: null == currentNdvi
          ? _value.currentNdvi
          : currentNdvi // ignore: cast_nullable_to_non_nullable
              as double,
      currentYieldForecast: null == currentYieldForecast
          ? _value.currentYieldForecast
          : currentYieldForecast // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceLow: null == confidenceLow
          ? _value.confidenceLow
          : confidenceLow // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceHigh: null == confidenceHigh
          ? _value.confidenceHigh
          : confidenceHigh // ignore: cast_nullable_to_non_nullable
              as double,
      forecastCrop: null == forecastCrop
          ? _value.forecastCrop
          : forecastCrop // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DistrictImplCopyWith<$Res>
    implements $DistrictCopyWith<$Res> {
  factory _$$DistrictImplCopyWith(
          _$DistrictImpl value, $Res Function(_$DistrictImpl) then) =
      __$$DistrictImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String province,
      double lat,
      double lng,
      double riskScore,
      String riskLevel,
      double currentNdvi,
      double currentYieldForecast,
      double confidenceLow,
      double confidenceHigh,
      String forecastCrop,
      String? lastUpdated});
}

/// @nodoc
class __$$DistrictImplCopyWithImpl<$Res>
    extends _$DistrictCopyWithImpl<$Res, _$DistrictImpl>
    implements _$$DistrictImplCopyWith<$Res> {
  __$$DistrictImplCopyWithImpl(
      _$DistrictImpl _value, $Res Function(_$DistrictImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? province = null,
    Object? lat = null,
    Object? lng = null,
    Object? riskScore = null,
    Object? riskLevel = null,
    Object? currentNdvi = null,
    Object? currentYieldForecast = null,
    Object? confidenceLow = null,
    Object? confidenceHigh = null,
    Object? forecastCrop = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$DistrictImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      province: null == province
          ? _value.province
          : province // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      currentNdvi: null == currentNdvi
          ? _value.currentNdvi
          : currentNdvi // ignore: cast_nullable_to_non_nullable
              as double,
      currentYieldForecast: null == currentYieldForecast
          ? _value.currentYieldForecast
          : currentYieldForecast // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceLow: null == confidenceLow
          ? _value.confidenceLow
          : confidenceLow // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceHigh: null == confidenceHigh
          ? _value.confidenceHigh
          : confidenceHigh // ignore: cast_nullable_to_non_nullable
              as double,
      forecastCrop: null == forecastCrop
          ? _value.forecastCrop
          : forecastCrop // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DistrictImpl implements _District {
  const _$DistrictImpl(
      {required this.id,
      required this.name,
      required this.province,
      required this.lat,
      required this.lng,
      this.riskScore = 0.0,
      this.riskLevel = 'good',
      this.currentNdvi = 0.0,
      this.currentYieldForecast = 0.0,
      this.confidenceLow = 0.0,
      this.confidenceHigh = 0.0,
      this.forecastCrop = 'wheat',
      this.lastUpdated});

  factory _$DistrictImpl.fromJson(Map<String, dynamic> json) =>
      _$$DistrictImplFromJson(json);

// Unique identifier used in API calls: e.g., "faisalabad"
  @override
  final String id;
// Human-readable name: e.g., "Faisalabad"
  @override
  final String name;
// Province this district belongs to: e.g., "Punjab"
  @override
  final String province;
// Geographic center coordinates (used to position map markers)
  @override
  final double lat;
  @override
  final double lng;
// Risk score from 0 (perfect) to 100 (critical drought/disease)
  @override
  @JsonKey()
  final double riskScore;
// Risk level as a string: good / above / watch / high / critical
  @override
  @JsonKey()
  final String riskLevel;
// Current NDVI reading (0.0 = bare soil, 1.0 = dense healthy vegetation)
  @override
  @JsonKey()
  final double currentNdvi;
// Predicted yield for the next 14 days in tonnes/acre
  @override
  @JsonKey()
  final double currentYieldForecast;
// Confidence interval lower bound (statistical uncertainty range)
  @override
  @JsonKey()
  final double confidenceLow;
// Confidence interval upper bound
  @override
  @JsonKey()
  final double confidenceHigh;
// Which crop this forecast is for (default: wheat)
  @override
  @JsonKey()
  final String forecastCrop;
// When this data was last updated (ISO 8601 string from backend)
  @override
  final String? lastUpdated;

  @override
  String toString() {
    return 'District(id: $id, name: $name, province: $province, lat: $lat, lng: $lng, riskScore: $riskScore, riskLevel: $riskLevel, currentNdvi: $currentNdvi, currentYieldForecast: $currentYieldForecast, confidenceLow: $confidenceLow, confidenceHigh: $confidenceHigh, forecastCrop: $forecastCrop, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DistrictImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.province, province) ||
                other.province == province) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.currentNdvi, currentNdvi) ||
                other.currentNdvi == currentNdvi) &&
            (identical(other.currentYieldForecast, currentYieldForecast) ||
                other.currentYieldForecast == currentYieldForecast) &&
            (identical(other.confidenceLow, confidenceLow) ||
                other.confidenceLow == confidenceLow) &&
            (identical(other.confidenceHigh, confidenceHigh) ||
                other.confidenceHigh == confidenceHigh) &&
            (identical(other.forecastCrop, forecastCrop) ||
                other.forecastCrop == forecastCrop) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      province,
      lat,
      lng,
      riskScore,
      riskLevel,
      currentNdvi,
      currentYieldForecast,
      confidenceLow,
      confidenceHigh,
      forecastCrop,
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DistrictImplCopyWith<_$DistrictImpl> get copyWith =>
      __$$DistrictImplCopyWithImpl<_$DistrictImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DistrictImplToJson(
      this,
    );
  }
}

abstract class _District implements District {
  const factory _District(
      {required final String id,
      required final String name,
      required final String province,
      required final double lat,
      required final double lng,
      final double riskScore,
      final String riskLevel,
      final double currentNdvi,
      final double currentYieldForecast,
      final double confidenceLow,
      final double confidenceHigh,
      final String forecastCrop,
      final String? lastUpdated}) = _$DistrictImpl;

  factory _District.fromJson(Map<String, dynamic> json) =
      _$DistrictImpl.fromJson;

  @override // Unique identifier used in API calls: e.g., "faisalabad"
  String get id;
  @override // Human-readable name: e.g., "Faisalabad"
  String get name;
  @override // Province this district belongs to: e.g., "Punjab"
  String get province;
  @override // Geographic center coordinates (used to position map markers)
  double get lat;
  @override
  double get lng;
  @override // Risk score from 0 (perfect) to 100 (critical drought/disease)
  double get riskScore;
  @override // Risk level as a string: good / above / watch / high / critical
  String get riskLevel;
  @override // Current NDVI reading (0.0 = bare soil, 1.0 = dense healthy vegetation)
  double get currentNdvi;
  @override // Predicted yield for the next 14 days in tonnes/acre
  double get currentYieldForecast;
  @override // Confidence interval lower bound (statistical uncertainty range)
  double get confidenceLow;
  @override // Confidence interval upper bound
  double get confidenceHigh;
  @override // Which crop this forecast is for (default: wheat)
  String get forecastCrop;
  @override // When this data was last updated (ISO 8601 string from backend)
  String? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$DistrictImplCopyWith<_$DistrictImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
