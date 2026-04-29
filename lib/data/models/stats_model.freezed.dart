// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StatsModel _$StatsModelFromJson(Map<String, dynamic> json) {
  return _StatsModel.fromJson(json);
}

/// @nodoc
mixin _$StatsModel {
  String get district => throw _privateConstructorUsedError;
  String get crop =>
      throw _privateConstructorUsedError; // ── Descriptive Statistics ────────────────────────────────────
// All yield values are in tonnes/acre
  double get mean =>
      throw _privateConstructorUsedError; // Average yield over all years
  double get median =>
      throw _privateConstructorUsedError; // Middle value (less affected by outliers)
  double get std =>
      throw _privateConstructorUsedError; // Standard deviation (spread of data)
  double get min => throw _privateConstructorUsedError; // Lowest recorded yield
  double get max =>
      throw _privateConstructorUsedError; // Highest recorded yield
  double get q1 => throw _privateConstructorUsedError; // 25th percentile
  double get q3 => throw _privateConstructorUsedError; // 75th percentile
// ── Trend Analysis ────────────────────────────────────────────
  TrendDirection get trendDirection =>
      throw _privateConstructorUsedError; // Linear trend slope: tonnes/acre increase per year (can be negative)
  double get trendSlope =>
      throw _privateConstructorUsedError; // ── Hypothesis Testing (t-test: is yield significantly above threshold?) ─
// p-value from one-sample t-test (< 0.05 means statistically significant)
  double get pValue =>
      throw _privateConstructorUsedError; // ── Regression Model Performance ──────────────────────────────
// R² score: 0.0 = model explains nothing, 1.0 = perfect prediction
  double get rSquared =>
      throw _privateConstructorUsedError; // RMSE: Root Mean Squared Error in tonnes/acre (lower = better)
  double get rmse =>
      throw _privateConstructorUsedError; // ── Drought Probability ────────────────────────────────────────
// Probability that yield falls below drought threshold (0.0–1.0)
  double get droughtProbability =>
      throw _privateConstructorUsedError; // Drought threshold yield in tonnes/acre (below this = drought)
  double get droughtThreshold =>
      throw _privateConstructorUsedError; // ── Sample Info ───────────────────────────────────────────────
// Number of years of data used in analysis
  int get sampleSize =>
      throw _privateConstructorUsedError; // Year range: "2005–2023"
  String get yearRange => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StatsModelCopyWith<StatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsModelCopyWith<$Res> {
  factory $StatsModelCopyWith(
          StatsModel value, $Res Function(StatsModel) then) =
      _$StatsModelCopyWithImpl<$Res, StatsModel>;
  @useResult
  $Res call(
      {String district,
      String crop,
      double mean,
      double median,
      double std,
      double min,
      double max,
      double q1,
      double q3,
      TrendDirection trendDirection,
      double trendSlope,
      double pValue,
      double rSquared,
      double rmse,
      double droughtProbability,
      double droughtThreshold,
      int sampleSize,
      String yearRange});
}

/// @nodoc
class _$StatsModelCopyWithImpl<$Res, $Val extends StatsModel>
    implements $StatsModelCopyWith<$Res> {
  _$StatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? crop = null,
    Object? mean = null,
    Object? median = null,
    Object? std = null,
    Object? min = null,
    Object? max = null,
    Object? q1 = null,
    Object? q3 = null,
    Object? trendDirection = null,
    Object? trendSlope = null,
    Object? pValue = null,
    Object? rSquared = null,
    Object? rmse = null,
    Object? droughtProbability = null,
    Object? droughtThreshold = null,
    Object? sampleSize = null,
    Object? yearRange = null,
  }) {
    return _then(_value.copyWith(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      crop: null == crop
          ? _value.crop
          : crop // ignore: cast_nullable_to_non_nullable
              as String,
      mean: null == mean
          ? _value.mean
          : mean // ignore: cast_nullable_to_non_nullable
              as double,
      median: null == median
          ? _value.median
          : median // ignore: cast_nullable_to_non_nullable
              as double,
      std: null == std
          ? _value.std
          : std // ignore: cast_nullable_to_non_nullable
              as double,
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
      q1: null == q1
          ? _value.q1
          : q1 // ignore: cast_nullable_to_non_nullable
              as double,
      q3: null == q3
          ? _value.q3
          : q3 // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      trendSlope: null == trendSlope
          ? _value.trendSlope
          : trendSlope // ignore: cast_nullable_to_non_nullable
              as double,
      pValue: null == pValue
          ? _value.pValue
          : pValue // ignore: cast_nullable_to_non_nullable
              as double,
      rSquared: null == rSquared
          ? _value.rSquared
          : rSquared // ignore: cast_nullable_to_non_nullable
              as double,
      rmse: null == rmse
          ? _value.rmse
          : rmse // ignore: cast_nullable_to_non_nullable
              as double,
      droughtProbability: null == droughtProbability
          ? _value.droughtProbability
          : droughtProbability // ignore: cast_nullable_to_non_nullable
              as double,
      droughtThreshold: null == droughtThreshold
          ? _value.droughtThreshold
          : droughtThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      sampleSize: null == sampleSize
          ? _value.sampleSize
          : sampleSize // ignore: cast_nullable_to_non_nullable
              as int,
      yearRange: null == yearRange
          ? _value.yearRange
          : yearRange // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatsModelImplCopyWith<$Res>
    implements $StatsModelCopyWith<$Res> {
  factory _$$StatsModelImplCopyWith(
          _$StatsModelImpl value, $Res Function(_$StatsModelImpl) then) =
      __$$StatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String district,
      String crop,
      double mean,
      double median,
      double std,
      double min,
      double max,
      double q1,
      double q3,
      TrendDirection trendDirection,
      double trendSlope,
      double pValue,
      double rSquared,
      double rmse,
      double droughtProbability,
      double droughtThreshold,
      int sampleSize,
      String yearRange});
}

/// @nodoc
class __$$StatsModelImplCopyWithImpl<$Res>
    extends _$StatsModelCopyWithImpl<$Res, _$StatsModelImpl>
    implements _$$StatsModelImplCopyWith<$Res> {
  __$$StatsModelImplCopyWithImpl(
      _$StatsModelImpl _value, $Res Function(_$StatsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? crop = null,
    Object? mean = null,
    Object? median = null,
    Object? std = null,
    Object? min = null,
    Object? max = null,
    Object? q1 = null,
    Object? q3 = null,
    Object? trendDirection = null,
    Object? trendSlope = null,
    Object? pValue = null,
    Object? rSquared = null,
    Object? rmse = null,
    Object? droughtProbability = null,
    Object? droughtThreshold = null,
    Object? sampleSize = null,
    Object? yearRange = null,
  }) {
    return _then(_$StatsModelImpl(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      crop: null == crop
          ? _value.crop
          : crop // ignore: cast_nullable_to_non_nullable
              as String,
      mean: null == mean
          ? _value.mean
          : mean // ignore: cast_nullable_to_non_nullable
              as double,
      median: null == median
          ? _value.median
          : median // ignore: cast_nullable_to_non_nullable
              as double,
      std: null == std
          ? _value.std
          : std // ignore: cast_nullable_to_non_nullable
              as double,
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
      q1: null == q1
          ? _value.q1
          : q1 // ignore: cast_nullable_to_non_nullable
              as double,
      q3: null == q3
          ? _value.q3
          : q3 // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      trendSlope: null == trendSlope
          ? _value.trendSlope
          : trendSlope // ignore: cast_nullable_to_non_nullable
              as double,
      pValue: null == pValue
          ? _value.pValue
          : pValue // ignore: cast_nullable_to_non_nullable
              as double,
      rSquared: null == rSquared
          ? _value.rSquared
          : rSquared // ignore: cast_nullable_to_non_nullable
              as double,
      rmse: null == rmse
          ? _value.rmse
          : rmse // ignore: cast_nullable_to_non_nullable
              as double,
      droughtProbability: null == droughtProbability
          ? _value.droughtProbability
          : droughtProbability // ignore: cast_nullable_to_non_nullable
              as double,
      droughtThreshold: null == droughtThreshold
          ? _value.droughtThreshold
          : droughtThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      sampleSize: null == sampleSize
          ? _value.sampleSize
          : sampleSize // ignore: cast_nullable_to_non_nullable
              as int,
      yearRange: null == yearRange
          ? _value.yearRange
          : yearRange // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsModelImpl implements _StatsModel {
  const _$StatsModelImpl(
      {required this.district,
      required this.crop,
      required this.mean,
      required this.median,
      required this.std,
      required this.min,
      required this.max,
      required this.q1,
      required this.q3,
      required this.trendDirection,
      required this.trendSlope,
      required this.pValue,
      required this.rSquared,
      required this.rmse,
      this.droughtProbability = 0.0,
      this.droughtThreshold = 1.0,
      this.sampleSize = 19,
      this.yearRange = '2005–2023'});

  factory _$StatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsModelImplFromJson(json);

  @override
  final String district;
  @override
  final String crop;
// ── Descriptive Statistics ────────────────────────────────────
// All yield values are in tonnes/acre
  @override
  final double mean;
// Average yield over all years
  @override
  final double median;
// Middle value (less affected by outliers)
  @override
  final double std;
// Standard deviation (spread of data)
  @override
  final double min;
// Lowest recorded yield
  @override
  final double max;
// Highest recorded yield
  @override
  final double q1;
// 25th percentile
  @override
  final double q3;
// 75th percentile
// ── Trend Analysis ────────────────────────────────────────────
  @override
  final TrendDirection trendDirection;
// Linear trend slope: tonnes/acre increase per year (can be negative)
  @override
  final double trendSlope;
// ── Hypothesis Testing (t-test: is yield significantly above threshold?) ─
// p-value from one-sample t-test (< 0.05 means statistically significant)
  @override
  final double pValue;
// ── Regression Model Performance ──────────────────────────────
// R² score: 0.0 = model explains nothing, 1.0 = perfect prediction
  @override
  final double rSquared;
// RMSE: Root Mean Squared Error in tonnes/acre (lower = better)
  @override
  final double rmse;
// ── Drought Probability ────────────────────────────────────────
// Probability that yield falls below drought threshold (0.0–1.0)
  @override
  @JsonKey()
  final double droughtProbability;
// Drought threshold yield in tonnes/acre (below this = drought)
  @override
  @JsonKey()
  final double droughtThreshold;
// ── Sample Info ───────────────────────────────────────────────
// Number of years of data used in analysis
  @override
  @JsonKey()
  final int sampleSize;
// Year range: "2005–2023"
  @override
  @JsonKey()
  final String yearRange;

  @override
  String toString() {
    return 'StatsModel(district: $district, crop: $crop, mean: $mean, median: $median, std: $std, min: $min, max: $max, q1: $q1, q3: $q3, trendDirection: $trendDirection, trendSlope: $trendSlope, pValue: $pValue, rSquared: $rSquared, rmse: $rmse, droughtProbability: $droughtProbability, droughtThreshold: $droughtThreshold, sampleSize: $sampleSize, yearRange: $yearRange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsModelImpl &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.crop, crop) || other.crop == crop) &&
            (identical(other.mean, mean) || other.mean == mean) &&
            (identical(other.median, median) || other.median == median) &&
            (identical(other.std, std) || other.std == std) &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.q1, q1) || other.q1 == q1) &&
            (identical(other.q3, q3) || other.q3 == q3) &&
            (identical(other.trendDirection, trendDirection) ||
                other.trendDirection == trendDirection) &&
            (identical(other.trendSlope, trendSlope) ||
                other.trendSlope == trendSlope) &&
            (identical(other.pValue, pValue) || other.pValue == pValue) &&
            (identical(other.rSquared, rSquared) ||
                other.rSquared == rSquared) &&
            (identical(other.rmse, rmse) || other.rmse == rmse) &&
            (identical(other.droughtProbability, droughtProbability) ||
                other.droughtProbability == droughtProbability) &&
            (identical(other.droughtThreshold, droughtThreshold) ||
                other.droughtThreshold == droughtThreshold) &&
            (identical(other.sampleSize, sampleSize) ||
                other.sampleSize == sampleSize) &&
            (identical(other.yearRange, yearRange) ||
                other.yearRange == yearRange));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      district,
      crop,
      mean,
      median,
      std,
      min,
      max,
      q1,
      q3,
      trendDirection,
      trendSlope,
      pValue,
      rSquared,
      rmse,
      droughtProbability,
      droughtThreshold,
      sampleSize,
      yearRange);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsModelImplCopyWith<_$StatsModelImpl> get copyWith =>
      __$$StatsModelImplCopyWithImpl<_$StatsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsModelImplToJson(
      this,
    );
  }
}

abstract class _StatsModel implements StatsModel {
  const factory _StatsModel(
      {required final String district,
      required final String crop,
      required final double mean,
      required final double median,
      required final double std,
      required final double min,
      required final double max,
      required final double q1,
      required final double q3,
      required final TrendDirection trendDirection,
      required final double trendSlope,
      required final double pValue,
      required final double rSquared,
      required final double rmse,
      final double droughtProbability,
      final double droughtThreshold,
      final int sampleSize,
      final String yearRange}) = _$StatsModelImpl;

  factory _StatsModel.fromJson(Map<String, dynamic> json) =
      _$StatsModelImpl.fromJson;

  @override
  String get district;
  @override
  String get crop;
  @override // ── Descriptive Statistics ────────────────────────────────────
// All yield values are in tonnes/acre
  double get mean;
  @override // Average yield over all years
  double get median;
  @override // Middle value (less affected by outliers)
  double get std;
  @override // Standard deviation (spread of data)
  double get min;
  @override // Lowest recorded yield
  double get max;
  @override // Highest recorded yield
  double get q1;
  @override // 25th percentile
  double get q3;
  @override // 75th percentile
// ── Trend Analysis ────────────────────────────────────────────
  TrendDirection get trendDirection;
  @override // Linear trend slope: tonnes/acre increase per year (can be negative)
  double get trendSlope;
  @override // ── Hypothesis Testing (t-test: is yield significantly above threshold?) ─
// p-value from one-sample t-test (< 0.05 means statistically significant)
  double get pValue;
  @override // ── Regression Model Performance ──────────────────────────────
// R² score: 0.0 = model explains nothing, 1.0 = perfect prediction
  double get rSquared;
  @override // RMSE: Root Mean Squared Error in tonnes/acre (lower = better)
  double get rmse;
  @override // ── Drought Probability ────────────────────────────────────────
// Probability that yield falls below drought threshold (0.0–1.0)
  double get droughtProbability;
  @override // Drought threshold yield in tonnes/acre (below this = drought)
  double get droughtThreshold;
  @override // ── Sample Info ───────────────────────────────────────────────
// Number of years of data used in analysis
  int get sampleSize;
  @override // Year range: "2005–2023"
  String get yearRange;
  @override
  @JsonKey(ignore: true)
  _$$StatsModelImplCopyWith<_$StatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsResponse _$StatsResponseFromJson(Map<String, dynamic> json) {
  return _StatsResponse.fromJson(json);
}

/// @nodoc
mixin _$StatsResponse {
  String get district =>
      throw _privateConstructorUsedError; // Key = crop id (e.g., "wheat"), Value = stats for that crop
  Map<String, StatsModel> get byCrop => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StatsResponseCopyWith<StatsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsResponseCopyWith<$Res> {
  factory $StatsResponseCopyWith(
          StatsResponse value, $Res Function(StatsResponse) then) =
      _$StatsResponseCopyWithImpl<$Res, StatsResponse>;
  @useResult
  $Res call({String district, Map<String, StatsModel> byCrop});
}

/// @nodoc
class _$StatsResponseCopyWithImpl<$Res, $Val extends StatsResponse>
    implements $StatsResponseCopyWith<$Res> {
  _$StatsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? byCrop = null,
  }) {
    return _then(_value.copyWith(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      byCrop: null == byCrop
          ? _value.byCrop
          : byCrop // ignore: cast_nullable_to_non_nullable
              as Map<String, StatsModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatsResponseImplCopyWith<$Res>
    implements $StatsResponseCopyWith<$Res> {
  factory _$$StatsResponseImplCopyWith(
          _$StatsResponseImpl value, $Res Function(_$StatsResponseImpl) then) =
      __$$StatsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String district, Map<String, StatsModel> byCrop});
}

/// @nodoc
class __$$StatsResponseImplCopyWithImpl<$Res>
    extends _$StatsResponseCopyWithImpl<$Res, _$StatsResponseImpl>
    implements _$$StatsResponseImplCopyWith<$Res> {
  __$$StatsResponseImplCopyWithImpl(
      _$StatsResponseImpl _value, $Res Function(_$StatsResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? byCrop = null,
  }) {
    return _then(_$StatsResponseImpl(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      byCrop: null == byCrop
          ? _value._byCrop
          : byCrop // ignore: cast_nullable_to_non_nullable
              as Map<String, StatsModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsResponseImpl implements _StatsResponse {
  const _$StatsResponseImpl(
      {required this.district, required final Map<String, StatsModel> byCrop})
      : _byCrop = byCrop;

  factory _$StatsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsResponseImplFromJson(json);

  @override
  final String district;
// Key = crop id (e.g., "wheat"), Value = stats for that crop
  final Map<String, StatsModel> _byCrop;
// Key = crop id (e.g., "wheat"), Value = stats for that crop
  @override
  Map<String, StatsModel> get byCrop {
    if (_byCrop is EqualUnmodifiableMapView) return _byCrop;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byCrop);
  }

  @override
  String toString() {
    return 'StatsResponse(district: $district, byCrop: $byCrop)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsResponseImpl &&
            (identical(other.district, district) ||
                other.district == district) &&
            const DeepCollectionEquality().equals(other._byCrop, _byCrop));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, district, const DeepCollectionEquality().hash(_byCrop));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsResponseImplCopyWith<_$StatsResponseImpl> get copyWith =>
      __$$StatsResponseImplCopyWithImpl<_$StatsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsResponseImplToJson(
      this,
    );
  }
}

abstract class _StatsResponse implements StatsResponse {
  const factory _StatsResponse(
      {required final String district,
      required final Map<String, StatsModel> byCrop}) = _$StatsResponseImpl;

  factory _StatsResponse.fromJson(Map<String, dynamic> json) =
      _$StatsResponseImpl.fromJson;

  @override
  String get district;
  @override // Key = crop id (e.g., "wheat"), Value = stats for that crop
  Map<String, StatsModel> get byCrop;
  @override
  @JsonKey(ignore: true)
  _$$StatsResponseImplCopyWith<_$StatsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
