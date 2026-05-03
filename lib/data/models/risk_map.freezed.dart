// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'risk_map.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RiskMapEntry _$RiskMapEntryFromJson(Map<String, dynamic> json) {
  return _RiskMapEntry.fromJson(json);
}

/// @nodoc
mixin _$RiskMapEntry {
// District identifier: e.g., "faisalabad"
  String get district =>
      throw _privateConstructorUsedError; // Human-readable district name
  String get districtName =>
      throw _privateConstructorUsedError; // Province name
  String get province =>
      throw _privateConstructorUsedError; // Typed risk level enum (good/above/watch/high/critical)
  RiskLevel get riskLevel =>
      throw _privateConstructorUsedError; // Numeric risk score 0–100 (used for risk meter gauge)
  double get riskScore =>
      throw _privateConstructorUsedError; // Yield forecasts per crop: { "wheat": 2.3, "rice": 1.8, ... }
// Using Map<String, double> because crops may vary by district
  Map<String, double> get cropYields => throw _privateConstructorUsedError;
  String get selectedCrop => throw _privateConstructorUsedError;
  int? get selectedYear => throw _privateConstructorUsedError;
  double? get yieldTAcre => throw _privateConstructorUsedError;
  double? get productionTons => throw _privateConstructorUsedError;
  double? get rainfallMm => throw _privateConstructorUsedError;
  double? get yieldChangePct => throw _privateConstructorUsedError;
  bool get dataAvailable => throw _privateConstructorUsedError;
  String get dataSource => throw _privateConstructorUsedError;
  List<String> get weatherRisks => throw _privateConstructorUsedError;
  List<String> get cropRisks => throw _privateConstructorUsedError;
  String get aiExplanation => throw _privateConstructorUsedError;
  List<String> get limitations =>
      throw _privateConstructorUsedError; // Current NDVI for quick display on map tooltip
  double get ndvi =>
      throw _privateConstructorUsedError; // Number of active alerts for this district
  int get alertCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RiskMapEntryCopyWith<RiskMapEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskMapEntryCopyWith<$Res> {
  factory $RiskMapEntryCopyWith(
          RiskMapEntry value, $Res Function(RiskMapEntry) then) =
      _$RiskMapEntryCopyWithImpl<$Res, RiskMapEntry>;
  @useResult
  $Res call(
      {String district,
      String districtName,
      String province,
      RiskLevel riskLevel,
      double riskScore,
      Map<String, double> cropYields,
      String selectedCrop,
      int? selectedYear,
      double? yieldTAcre,
      double? productionTons,
      double? rainfallMm,
      double? yieldChangePct,
      bool dataAvailable,
      String dataSource,
      List<String> weatherRisks,
      List<String> cropRisks,
      String aiExplanation,
      List<String> limitations,
      double ndvi,
      int alertCount});
}

/// @nodoc
class _$RiskMapEntryCopyWithImpl<$Res, $Val extends RiskMapEntry>
    implements $RiskMapEntryCopyWith<$Res> {
  _$RiskMapEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? districtName = null,
    Object? province = null,
    Object? riskLevel = null,
    Object? riskScore = null,
    Object? cropYields = null,
    Object? selectedCrop = null,
    Object? selectedYear = freezed,
    Object? yieldTAcre = freezed,
    Object? productionTons = freezed,
    Object? rainfallMm = freezed,
    Object? yieldChangePct = freezed,
    Object? dataAvailable = null,
    Object? dataSource = null,
    Object? weatherRisks = null,
    Object? cropRisks = null,
    Object? aiExplanation = null,
    Object? limitations = null,
    Object? ndvi = null,
    Object? alertCount = null,
  }) {
    return _then(_value.copyWith(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      districtName: null == districtName
          ? _value.districtName
          : districtName // ignore: cast_nullable_to_non_nullable
              as String,
      province: null == province
          ? _value.province
          : province // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as RiskLevel,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      cropYields: null == cropYields
          ? _value.cropYields
          : cropYields // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      selectedCrop: null == selectedCrop
          ? _value.selectedCrop
          : selectedCrop // ignore: cast_nullable_to_non_nullable
              as String,
      selectedYear: freezed == selectedYear
          ? _value.selectedYear
          : selectedYear // ignore: cast_nullable_to_non_nullable
              as int?,
      yieldTAcre: freezed == yieldTAcre
          ? _value.yieldTAcre
          : yieldTAcre // ignore: cast_nullable_to_non_nullable
              as double?,
      productionTons: freezed == productionTons
          ? _value.productionTons
          : productionTons // ignore: cast_nullable_to_non_nullable
              as double?,
      rainfallMm: freezed == rainfallMm
          ? _value.rainfallMm
          : rainfallMm // ignore: cast_nullable_to_non_nullable
              as double?,
      yieldChangePct: freezed == yieldChangePct
          ? _value.yieldChangePct
          : yieldChangePct // ignore: cast_nullable_to_non_nullable
              as double?,
      dataAvailable: null == dataAvailable
          ? _value.dataAvailable
          : dataAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      dataSource: null == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String,
      weatherRisks: null == weatherRisks
          ? _value.weatherRisks
          : weatherRisks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cropRisks: null == cropRisks
          ? _value.cropRisks
          : cropRisks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      aiExplanation: null == aiExplanation
          ? _value.aiExplanation
          : aiExplanation // ignore: cast_nullable_to_non_nullable
              as String,
      limitations: null == limitations
          ? _value.limitations
          : limitations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ndvi: null == ndvi
          ? _value.ndvi
          : ndvi // ignore: cast_nullable_to_non_nullable
              as double,
      alertCount: null == alertCount
          ? _value.alertCount
          : alertCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskMapEntryImplCopyWith<$Res>
    implements $RiskMapEntryCopyWith<$Res> {
  factory _$$RiskMapEntryImplCopyWith(
          _$RiskMapEntryImpl value, $Res Function(_$RiskMapEntryImpl) then) =
      __$$RiskMapEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String district,
      String districtName,
      String province,
      RiskLevel riskLevel,
      double riskScore,
      Map<String, double> cropYields,
      String selectedCrop,
      int? selectedYear,
      double? yieldTAcre,
      double? productionTons,
      double? rainfallMm,
      double? yieldChangePct,
      bool dataAvailable,
      String dataSource,
      List<String> weatherRisks,
      List<String> cropRisks,
      String aiExplanation,
      List<String> limitations,
      double ndvi,
      int alertCount});
}

/// @nodoc
class __$$RiskMapEntryImplCopyWithImpl<$Res>
    extends _$RiskMapEntryCopyWithImpl<$Res, _$RiskMapEntryImpl>
    implements _$$RiskMapEntryImplCopyWith<$Res> {
  __$$RiskMapEntryImplCopyWithImpl(
      _$RiskMapEntryImpl _value, $Res Function(_$RiskMapEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? districtName = null,
    Object? province = null,
    Object? riskLevel = null,
    Object? riskScore = null,
    Object? cropYields = null,
    Object? selectedCrop = null,
    Object? selectedYear = freezed,
    Object? yieldTAcre = freezed,
    Object? productionTons = freezed,
    Object? rainfallMm = freezed,
    Object? yieldChangePct = freezed,
    Object? dataAvailable = null,
    Object? dataSource = null,
    Object? weatherRisks = null,
    Object? cropRisks = null,
    Object? aiExplanation = null,
    Object? limitations = null,
    Object? ndvi = null,
    Object? alertCount = null,
  }) {
    return _then(_$RiskMapEntryImpl(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      districtName: null == districtName
          ? _value.districtName
          : districtName // ignore: cast_nullable_to_non_nullable
              as String,
      province: null == province
          ? _value.province
          : province // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as RiskLevel,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      cropYields: null == cropYields
          ? _value._cropYields
          : cropYields // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      selectedCrop: null == selectedCrop
          ? _value.selectedCrop
          : selectedCrop // ignore: cast_nullable_to_non_nullable
              as String,
      selectedYear: freezed == selectedYear
          ? _value.selectedYear
          : selectedYear // ignore: cast_nullable_to_non_nullable
              as int?,
      yieldTAcre: freezed == yieldTAcre
          ? _value.yieldTAcre
          : yieldTAcre // ignore: cast_nullable_to_non_nullable
              as double?,
      productionTons: freezed == productionTons
          ? _value.productionTons
          : productionTons // ignore: cast_nullable_to_non_nullable
              as double?,
      rainfallMm: freezed == rainfallMm
          ? _value.rainfallMm
          : rainfallMm // ignore: cast_nullable_to_non_nullable
              as double?,
      yieldChangePct: freezed == yieldChangePct
          ? _value.yieldChangePct
          : yieldChangePct // ignore: cast_nullable_to_non_nullable
              as double?,
      dataAvailable: null == dataAvailable
          ? _value.dataAvailable
          : dataAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      dataSource: null == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String,
      weatherRisks: null == weatherRisks
          ? _value._weatherRisks
          : weatherRisks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cropRisks: null == cropRisks
          ? _value._cropRisks
          : cropRisks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      aiExplanation: null == aiExplanation
          ? _value.aiExplanation
          : aiExplanation // ignore: cast_nullable_to_non_nullable
              as String,
      limitations: null == limitations
          ? _value._limitations
          : limitations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ndvi: null == ndvi
          ? _value.ndvi
          : ndvi // ignore: cast_nullable_to_non_nullable
              as double,
      alertCount: null == alertCount
          ? _value.alertCount
          : alertCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskMapEntryImpl implements _RiskMapEntry {
  const _$RiskMapEntryImpl(
      {required this.district,
      required this.districtName,
      required this.province,
      required this.riskLevel,
      required this.riskScore,
      final Map<String, double> cropYields = const {},
      this.selectedCrop = '',
      this.selectedYear,
      this.yieldTAcre,
      this.productionTons,
      this.rainfallMm,
      this.yieldChangePct,
      this.dataAvailable = true,
      this.dataSource = '',
      final List<String> weatherRisks = const [],
      final List<String> cropRisks = const [],
      this.aiExplanation = '',
      final List<String> limitations = const [],
      this.ndvi = 0.0,
      this.alertCount = 0})
      : _cropYields = cropYields,
        _weatherRisks = weatherRisks,
        _cropRisks = cropRisks,
        _limitations = limitations;

  factory _$RiskMapEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskMapEntryImplFromJson(json);

// District identifier: e.g., "faisalabad"
  @override
  final String district;
// Human-readable district name
  @override
  final String districtName;
// Province name
  @override
  final String province;
// Typed risk level enum (good/above/watch/high/critical)
  @override
  final RiskLevel riskLevel;
// Numeric risk score 0–100 (used for risk meter gauge)
  @override
  final double riskScore;
// Yield forecasts per crop: { "wheat": 2.3, "rice": 1.8, ... }
// Using Map<String, double> because crops may vary by district
  final Map<String, double> _cropYields;
// Yield forecasts per crop: { "wheat": 2.3, "rice": 1.8, ... }
// Using Map<String, double> because crops may vary by district
  @override
  @JsonKey()
  Map<String, double> get cropYields {
    if (_cropYields is EqualUnmodifiableMapView) return _cropYields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cropYields);
  }

  @override
  @JsonKey()
  final String selectedCrop;
  @override
  final int? selectedYear;
  @override
  final double? yieldTAcre;
  @override
  final double? productionTons;
  @override
  final double? rainfallMm;
  @override
  final double? yieldChangePct;
  @override
  @JsonKey()
  final bool dataAvailable;
  @override
  @JsonKey()
  final String dataSource;
  final List<String> _weatherRisks;
  @override
  @JsonKey()
  List<String> get weatherRisks {
    if (_weatherRisks is EqualUnmodifiableListView) return _weatherRisks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weatherRisks);
  }

  final List<String> _cropRisks;
  @override
  @JsonKey()
  List<String> get cropRisks {
    if (_cropRisks is EqualUnmodifiableListView) return _cropRisks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cropRisks);
  }

  @override
  @JsonKey()
  final String aiExplanation;
  final List<String> _limitations;
  @override
  @JsonKey()
  List<String> get limitations {
    if (_limitations is EqualUnmodifiableListView) return _limitations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_limitations);
  }

// Current NDVI for quick display on map tooltip
  @override
  @JsonKey()
  final double ndvi;
// Number of active alerts for this district
  @override
  @JsonKey()
  final int alertCount;

  @override
  String toString() {
    return 'RiskMapEntry(district: $district, districtName: $districtName, province: $province, riskLevel: $riskLevel, riskScore: $riskScore, cropYields: $cropYields, selectedCrop: $selectedCrop, selectedYear: $selectedYear, yieldTAcre: $yieldTAcre, productionTons: $productionTons, rainfallMm: $rainfallMm, yieldChangePct: $yieldChangePct, dataAvailable: $dataAvailable, dataSource: $dataSource, weatherRisks: $weatherRisks, cropRisks: $cropRisks, aiExplanation: $aiExplanation, limitations: $limitations, ndvi: $ndvi, alertCount: $alertCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskMapEntryImpl &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.districtName, districtName) ||
                other.districtName == districtName) &&
            (identical(other.province, province) ||
                other.province == province) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            const DeepCollectionEquality()
                .equals(other._cropYields, _cropYields) &&
            (identical(other.selectedCrop, selectedCrop) ||
                other.selectedCrop == selectedCrop) &&
            (identical(other.selectedYear, selectedYear) ||
                other.selectedYear == selectedYear) &&
            (identical(other.yieldTAcre, yieldTAcre) ||
                other.yieldTAcre == yieldTAcre) &&
            (identical(other.productionTons, productionTons) ||
                other.productionTons == productionTons) &&
            (identical(other.rainfallMm, rainfallMm) ||
                other.rainfallMm == rainfallMm) &&
            (identical(other.yieldChangePct, yieldChangePct) ||
                other.yieldChangePct == yieldChangePct) &&
            (identical(other.dataAvailable, dataAvailable) ||
                other.dataAvailable == dataAvailable) &&
            (identical(other.dataSource, dataSource) ||
                other.dataSource == dataSource) &&
            const DeepCollectionEquality()
                .equals(other._weatherRisks, _weatherRisks) &&
            const DeepCollectionEquality()
                .equals(other._cropRisks, _cropRisks) &&
            (identical(other.aiExplanation, aiExplanation) ||
                other.aiExplanation == aiExplanation) &&
            const DeepCollectionEquality()
                .equals(other._limitations, _limitations) &&
            (identical(other.ndvi, ndvi) || other.ndvi == ndvi) &&
            (identical(other.alertCount, alertCount) ||
                other.alertCount == alertCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        district,
        districtName,
        province,
        riskLevel,
        riskScore,
        const DeepCollectionEquality().hash(_cropYields),
        selectedCrop,
        selectedYear,
        yieldTAcre,
        productionTons,
        rainfallMm,
        yieldChangePct,
        dataAvailable,
        dataSource,
        const DeepCollectionEquality().hash(_weatherRisks),
        const DeepCollectionEquality().hash(_cropRisks),
        aiExplanation,
        const DeepCollectionEquality().hash(_limitations),
        ndvi,
        alertCount
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskMapEntryImplCopyWith<_$RiskMapEntryImpl> get copyWith =>
      __$$RiskMapEntryImplCopyWithImpl<_$RiskMapEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskMapEntryImplToJson(
      this,
    );
  }
}

abstract class _RiskMapEntry implements RiskMapEntry {
  const factory _RiskMapEntry(
      {required final String district,
      required final String districtName,
      required final String province,
      required final RiskLevel riskLevel,
      required final double riskScore,
      final Map<String, double> cropYields,
      final String selectedCrop,
      final int? selectedYear,
      final double? yieldTAcre,
      final double? productionTons,
      final double? rainfallMm,
      final double? yieldChangePct,
      final bool dataAvailable,
      final String dataSource,
      final List<String> weatherRisks,
      final List<String> cropRisks,
      final String aiExplanation,
      final List<String> limitations,
      final double ndvi,
      final int alertCount}) = _$RiskMapEntryImpl;

  factory _RiskMapEntry.fromJson(Map<String, dynamic> json) =
      _$RiskMapEntryImpl.fromJson;

  @override // District identifier: e.g., "faisalabad"
  String get district;
  @override // Human-readable district name
  String get districtName;
  @override // Province name
  String get province;
  @override // Typed risk level enum (good/above/watch/high/critical)
  RiskLevel get riskLevel;
  @override // Numeric risk score 0–100 (used for risk meter gauge)
  double get riskScore;
  @override // Yield forecasts per crop: { "wheat": 2.3, "rice": 1.8, ... }
// Using Map<String, double> because crops may vary by district
  Map<String, double> get cropYields;
  @override
  String get selectedCrop;
  @override
  int? get selectedYear;
  @override
  double? get yieldTAcre;
  @override
  double? get productionTons;
  @override
  double? get rainfallMm;
  @override
  double? get yieldChangePct;
  @override
  bool get dataAvailable;
  @override
  String get dataSource;
  @override
  List<String> get weatherRisks;
  @override
  List<String> get cropRisks;
  @override
  String get aiExplanation;
  @override
  List<String> get limitations;
  @override // Current NDVI for quick display on map tooltip
  double get ndvi;
  @override // Number of active alerts for this district
  int get alertCount;
  @override
  @JsonKey(ignore: true)
  _$$RiskMapEntryImplCopyWith<_$RiskMapEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RiskMapResponse _$RiskMapResponseFromJson(Map<String, dynamic> json) {
  return _RiskMapResponse.fromJson(json);
}

/// @nodoc
mixin _$RiskMapResponse {
// All 36 district entries
  List<RiskMapEntry> get districts =>
      throw _privateConstructorUsedError; // When this risk map was generated on the backend
  String get generatedAt =>
      throw _privateConstructorUsedError; // Overall Pakistan risk summary
  String get nationalRiskLevel => throw _privateConstructorUsedError;
  int get criticalCount => throw _privateConstructorUsedError;
  int get highCount => throw _privateConstructorUsedError;
  int get watchCount => throw _privateConstructorUsedError;
  String get selectedCrop => throw _privateConstructorUsedError;
  int? get selectedYear => throw _privateConstructorUsedError;
  String get yearRange => throw _privateConstructorUsedError;
  String get dataSource => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RiskMapResponseCopyWith<RiskMapResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskMapResponseCopyWith<$Res> {
  factory $RiskMapResponseCopyWith(
          RiskMapResponse value, $Res Function(RiskMapResponse) then) =
      _$RiskMapResponseCopyWithImpl<$Res, RiskMapResponse>;
  @useResult
  $Res call(
      {List<RiskMapEntry> districts,
      String generatedAt,
      String nationalRiskLevel,
      int criticalCount,
      int highCount,
      int watchCount,
      String selectedCrop,
      int? selectedYear,
      String yearRange,
      String dataSource});
}

/// @nodoc
class _$RiskMapResponseCopyWithImpl<$Res, $Val extends RiskMapResponse>
    implements $RiskMapResponseCopyWith<$Res> {
  _$RiskMapResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? districts = null,
    Object? generatedAt = null,
    Object? nationalRiskLevel = null,
    Object? criticalCount = null,
    Object? highCount = null,
    Object? watchCount = null,
    Object? selectedCrop = null,
    Object? selectedYear = freezed,
    Object? yearRange = null,
    Object? dataSource = null,
  }) {
    return _then(_value.copyWith(
      districts: null == districts
          ? _value.districts
          : districts // ignore: cast_nullable_to_non_nullable
              as List<RiskMapEntry>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      nationalRiskLevel: null == nationalRiskLevel
          ? _value.nationalRiskLevel
          : nationalRiskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      criticalCount: null == criticalCount
          ? _value.criticalCount
          : criticalCount // ignore: cast_nullable_to_non_nullable
              as int,
      highCount: null == highCount
          ? _value.highCount
          : highCount // ignore: cast_nullable_to_non_nullable
              as int,
      watchCount: null == watchCount
          ? _value.watchCount
          : watchCount // ignore: cast_nullable_to_non_nullable
              as int,
      selectedCrop: null == selectedCrop
          ? _value.selectedCrop
          : selectedCrop // ignore: cast_nullable_to_non_nullable
              as String,
      selectedYear: freezed == selectedYear
          ? _value.selectedYear
          : selectedYear // ignore: cast_nullable_to_non_nullable
              as int?,
      yearRange: null == yearRange
          ? _value.yearRange
          : yearRange // ignore: cast_nullable_to_non_nullable
              as String,
      dataSource: null == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskMapResponseImplCopyWith<$Res>
    implements $RiskMapResponseCopyWith<$Res> {
  factory _$$RiskMapResponseImplCopyWith(_$RiskMapResponseImpl value,
          $Res Function(_$RiskMapResponseImpl) then) =
      __$$RiskMapResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<RiskMapEntry> districts,
      String generatedAt,
      String nationalRiskLevel,
      int criticalCount,
      int highCount,
      int watchCount,
      String selectedCrop,
      int? selectedYear,
      String yearRange,
      String dataSource});
}

/// @nodoc
class __$$RiskMapResponseImplCopyWithImpl<$Res>
    extends _$RiskMapResponseCopyWithImpl<$Res, _$RiskMapResponseImpl>
    implements _$$RiskMapResponseImplCopyWith<$Res> {
  __$$RiskMapResponseImplCopyWithImpl(
      _$RiskMapResponseImpl _value, $Res Function(_$RiskMapResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? districts = null,
    Object? generatedAt = null,
    Object? nationalRiskLevel = null,
    Object? criticalCount = null,
    Object? highCount = null,
    Object? watchCount = null,
    Object? selectedCrop = null,
    Object? selectedYear = freezed,
    Object? yearRange = null,
    Object? dataSource = null,
  }) {
    return _then(_$RiskMapResponseImpl(
      districts: null == districts
          ? _value._districts
          : districts // ignore: cast_nullable_to_non_nullable
              as List<RiskMapEntry>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      nationalRiskLevel: null == nationalRiskLevel
          ? _value.nationalRiskLevel
          : nationalRiskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      criticalCount: null == criticalCount
          ? _value.criticalCount
          : criticalCount // ignore: cast_nullable_to_non_nullable
              as int,
      highCount: null == highCount
          ? _value.highCount
          : highCount // ignore: cast_nullable_to_non_nullable
              as int,
      watchCount: null == watchCount
          ? _value.watchCount
          : watchCount // ignore: cast_nullable_to_non_nullable
              as int,
      selectedCrop: null == selectedCrop
          ? _value.selectedCrop
          : selectedCrop // ignore: cast_nullable_to_non_nullable
              as String,
      selectedYear: freezed == selectedYear
          ? _value.selectedYear
          : selectedYear // ignore: cast_nullable_to_non_nullable
              as int?,
      yearRange: null == yearRange
          ? _value.yearRange
          : yearRange // ignore: cast_nullable_to_non_nullable
              as String,
      dataSource: null == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskMapResponseImpl implements _RiskMapResponse {
  const _$RiskMapResponseImpl(
      {required final List<RiskMapEntry> districts,
      required this.generatedAt,
      this.nationalRiskLevel = 'good',
      this.criticalCount = 0,
      this.highCount = 0,
      this.watchCount = 0,
      this.selectedCrop = '',
      this.selectedYear,
      this.yearRange = '',
      this.dataSource = ''})
      : _districts = districts;

  factory _$RiskMapResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskMapResponseImplFromJson(json);

// All 36 district entries
  final List<RiskMapEntry> _districts;
// All 36 district entries
  @override
  List<RiskMapEntry> get districts {
    if (_districts is EqualUnmodifiableListView) return _districts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_districts);
  }

// When this risk map was generated on the backend
  @override
  final String generatedAt;
// Overall Pakistan risk summary
  @override
  @JsonKey()
  final String nationalRiskLevel;
  @override
  @JsonKey()
  final int criticalCount;
  @override
  @JsonKey()
  final int highCount;
  @override
  @JsonKey()
  final int watchCount;
  @override
  @JsonKey()
  final String selectedCrop;
  @override
  final int? selectedYear;
  @override
  @JsonKey()
  final String yearRange;
  @override
  @JsonKey()
  final String dataSource;

  @override
  String toString() {
    return 'RiskMapResponse(districts: $districts, generatedAt: $generatedAt, nationalRiskLevel: $nationalRiskLevel, criticalCount: $criticalCount, highCount: $highCount, watchCount: $watchCount, selectedCrop: $selectedCrop, selectedYear: $selectedYear, yearRange: $yearRange, dataSource: $dataSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskMapResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._districts, _districts) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.nationalRiskLevel, nationalRiskLevel) ||
                other.nationalRiskLevel == nationalRiskLevel) &&
            (identical(other.criticalCount, criticalCount) ||
                other.criticalCount == criticalCount) &&
            (identical(other.highCount, highCount) ||
                other.highCount == highCount) &&
            (identical(other.watchCount, watchCount) ||
                other.watchCount == watchCount) &&
            (identical(other.selectedCrop, selectedCrop) ||
                other.selectedCrop == selectedCrop) &&
            (identical(other.selectedYear, selectedYear) ||
                other.selectedYear == selectedYear) &&
            (identical(other.yearRange, yearRange) ||
                other.yearRange == yearRange) &&
            (identical(other.dataSource, dataSource) ||
                other.dataSource == dataSource));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_districts),
      generatedAt,
      nationalRiskLevel,
      criticalCount,
      highCount,
      watchCount,
      selectedCrop,
      selectedYear,
      yearRange,
      dataSource);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskMapResponseImplCopyWith<_$RiskMapResponseImpl> get copyWith =>
      __$$RiskMapResponseImplCopyWithImpl<_$RiskMapResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskMapResponseImplToJson(
      this,
    );
  }
}

abstract class _RiskMapResponse implements RiskMapResponse {
  const factory _RiskMapResponse(
      {required final List<RiskMapEntry> districts,
      required final String generatedAt,
      final String nationalRiskLevel,
      final int criticalCount,
      final int highCount,
      final int watchCount,
      final String selectedCrop,
      final int? selectedYear,
      final String yearRange,
      final String dataSource}) = _$RiskMapResponseImpl;

  factory _RiskMapResponse.fromJson(Map<String, dynamic> json) =
      _$RiskMapResponseImpl.fromJson;

  @override // All 36 district entries
  List<RiskMapEntry> get districts;
  @override // When this risk map was generated on the backend
  String get generatedAt;
  @override // Overall Pakistan risk summary
  String get nationalRiskLevel;
  @override
  int get criticalCount;
  @override
  int get highCount;
  @override
  int get watchCount;
  @override
  String get selectedCrop;
  @override
  int? get selectedYear;
  @override
  String get yearRange;
  @override
  String get dataSource;
  @override
  @JsonKey(ignore: true)
  _$$RiskMapResponseImplCopyWith<_$RiskMapResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
