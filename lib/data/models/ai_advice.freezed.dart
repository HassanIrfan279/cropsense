// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_advice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIAdvice _$AIAdviceFromJson(Map<String, dynamic> json) {
  return _AIAdvice.fromJson(json);
}

/// @nodoc
mixin _$AIAdvice {
  String get alertUrdu => throw _privateConstructorUsedError;
  String get alertEnglish => throw _privateConstructorUsedError;
  String get diagnosis => throw _privateConstructorUsedError;
  double get confidencePct => throw _privateConstructorUsedError;
  List<String> get actionSteps => throw _privateConstructorUsedError;
  List<Medicine> get medicines => throw _privateConstructorUsedError;
  String get fertilizerAdvice => throw _privateConstructorUsedError;
  String get irrigationAdvice => throw _privateConstructorUsedError;
  double get totalCostPerAcrePkr => throw _privateConstructorUsedError;
  double get totalCostForFarmPkr => throw _privateConstructorUsedError;
  double get expectedYieldIncreasePct => throw _privateConstructorUsedError;
  String get roiNote => throw _privateConstructorUsedError;
  int get nextCheckupDays => throw _privateConstructorUsedError;
  String? get generatedAt => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get crop => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AIAdviceCopyWith<AIAdvice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIAdviceCopyWith<$Res> {
  factory $AIAdviceCopyWith(AIAdvice value, $Res Function(AIAdvice) then) =
      _$AIAdviceCopyWithImpl<$Res, AIAdvice>;
  @useResult
  $Res call(
      {String alertUrdu,
      String alertEnglish,
      String diagnosis,
      double confidencePct,
      List<String> actionSteps,
      List<Medicine> medicines,
      String fertilizerAdvice,
      String irrigationAdvice,
      double totalCostPerAcrePkr,
      double totalCostForFarmPkr,
      double expectedYieldIncreasePct,
      String roiNote,
      int nextCheckupDays,
      String? generatedAt,
      String? district,
      String? crop});
}

/// @nodoc
class _$AIAdviceCopyWithImpl<$Res, $Val extends AIAdvice>
    implements $AIAdviceCopyWith<$Res> {
  _$AIAdviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertUrdu = null,
    Object? alertEnglish = null,
    Object? diagnosis = null,
    Object? confidencePct = null,
    Object? actionSteps = null,
    Object? medicines = null,
    Object? fertilizerAdvice = null,
    Object? irrigationAdvice = null,
    Object? totalCostPerAcrePkr = null,
    Object? totalCostForFarmPkr = null,
    Object? expectedYieldIncreasePct = null,
    Object? roiNote = null,
    Object? nextCheckupDays = null,
    Object? generatedAt = freezed,
    Object? district = freezed,
    Object? crop = freezed,
  }) {
    return _then(_value.copyWith(
      alertUrdu: null == alertUrdu
          ? _value.alertUrdu
          : alertUrdu // ignore: cast_nullable_to_non_nullable
              as String,
      alertEnglish: null == alertEnglish
          ? _value.alertEnglish
          : alertEnglish // ignore: cast_nullable_to_non_nullable
              as String,
      diagnosis: null == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      confidencePct: null == confidencePct
          ? _value.confidencePct
          : confidencePct // ignore: cast_nullable_to_non_nullable
              as double,
      actionSteps: null == actionSteps
          ? _value.actionSteps
          : actionSteps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      medicines: null == medicines
          ? _value.medicines
          : medicines // ignore: cast_nullable_to_non_nullable
              as List<Medicine>,
      fertilizerAdvice: null == fertilizerAdvice
          ? _value.fertilizerAdvice
          : fertilizerAdvice // ignore: cast_nullable_to_non_nullable
              as String,
      irrigationAdvice: null == irrigationAdvice
          ? _value.irrigationAdvice
          : irrigationAdvice // ignore: cast_nullable_to_non_nullable
              as String,
      totalCostPerAcrePkr: null == totalCostPerAcrePkr
          ? _value.totalCostPerAcrePkr
          : totalCostPerAcrePkr // ignore: cast_nullable_to_non_nullable
              as double,
      totalCostForFarmPkr: null == totalCostForFarmPkr
          ? _value.totalCostForFarmPkr
          : totalCostForFarmPkr // ignore: cast_nullable_to_non_nullable
              as double,
      expectedYieldIncreasePct: null == expectedYieldIncreasePct
          ? _value.expectedYieldIncreasePct
          : expectedYieldIncreasePct // ignore: cast_nullable_to_non_nullable
              as double,
      roiNote: null == roiNote
          ? _value.roiNote
          : roiNote // ignore: cast_nullable_to_non_nullable
              as String,
      nextCheckupDays: null == nextCheckupDays
          ? _value.nextCheckupDays
          : nextCheckupDays // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      crop: freezed == crop
          ? _value.crop
          : crop // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIAdviceImplCopyWith<$Res>
    implements $AIAdviceCopyWith<$Res> {
  factory _$$AIAdviceImplCopyWith(
          _$AIAdviceImpl value, $Res Function(_$AIAdviceImpl) then) =
      __$$AIAdviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String alertUrdu,
      String alertEnglish,
      String diagnosis,
      double confidencePct,
      List<String> actionSteps,
      List<Medicine> medicines,
      String fertilizerAdvice,
      String irrigationAdvice,
      double totalCostPerAcrePkr,
      double totalCostForFarmPkr,
      double expectedYieldIncreasePct,
      String roiNote,
      int nextCheckupDays,
      String? generatedAt,
      String? district,
      String? crop});
}

/// @nodoc
class __$$AIAdviceImplCopyWithImpl<$Res>
    extends _$AIAdviceCopyWithImpl<$Res, _$AIAdviceImpl>
    implements _$$AIAdviceImplCopyWith<$Res> {
  __$$AIAdviceImplCopyWithImpl(
      _$AIAdviceImpl _value, $Res Function(_$AIAdviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertUrdu = null,
    Object? alertEnglish = null,
    Object? diagnosis = null,
    Object? confidencePct = null,
    Object? actionSteps = null,
    Object? medicines = null,
    Object? fertilizerAdvice = null,
    Object? irrigationAdvice = null,
    Object? totalCostPerAcrePkr = null,
    Object? totalCostForFarmPkr = null,
    Object? expectedYieldIncreasePct = null,
    Object? roiNote = null,
    Object? nextCheckupDays = null,
    Object? generatedAt = freezed,
    Object? district = freezed,
    Object? crop = freezed,
  }) {
    return _then(_$AIAdviceImpl(
      alertUrdu: null == alertUrdu
          ? _value.alertUrdu
          : alertUrdu // ignore: cast_nullable_to_non_nullable
              as String,
      alertEnglish: null == alertEnglish
          ? _value.alertEnglish
          : alertEnglish // ignore: cast_nullable_to_non_nullable
              as String,
      diagnosis: null == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      confidencePct: null == confidencePct
          ? _value.confidencePct
          : confidencePct // ignore: cast_nullable_to_non_nullable
              as double,
      actionSteps: null == actionSteps
          ? _value._actionSteps
          : actionSteps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      medicines: null == medicines
          ? _value._medicines
          : medicines // ignore: cast_nullable_to_non_nullable
              as List<Medicine>,
      fertilizerAdvice: null == fertilizerAdvice
          ? _value.fertilizerAdvice
          : fertilizerAdvice // ignore: cast_nullable_to_non_nullable
              as String,
      irrigationAdvice: null == irrigationAdvice
          ? _value.irrigationAdvice
          : irrigationAdvice // ignore: cast_nullable_to_non_nullable
              as String,
      totalCostPerAcrePkr: null == totalCostPerAcrePkr
          ? _value.totalCostPerAcrePkr
          : totalCostPerAcrePkr // ignore: cast_nullable_to_non_nullable
              as double,
      totalCostForFarmPkr: null == totalCostForFarmPkr
          ? _value.totalCostForFarmPkr
          : totalCostForFarmPkr // ignore: cast_nullable_to_non_nullable
              as double,
      expectedYieldIncreasePct: null == expectedYieldIncreasePct
          ? _value.expectedYieldIncreasePct
          : expectedYieldIncreasePct // ignore: cast_nullable_to_non_nullable
              as double,
      roiNote: null == roiNote
          ? _value.roiNote
          : roiNote // ignore: cast_nullable_to_non_nullable
              as String,
      nextCheckupDays: null == nextCheckupDays
          ? _value.nextCheckupDays
          : nextCheckupDays // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      crop: freezed == crop
          ? _value.crop
          : crop // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIAdviceImpl implements _AIAdvice {
  const _$AIAdviceImpl(
      {required this.alertUrdu,
      required this.alertEnglish,
      required this.diagnosis,
      required this.confidencePct,
      required final List<String> actionSteps,
      required final List<Medicine> medicines,
      required this.fertilizerAdvice,
      required this.irrigationAdvice,
      required this.totalCostPerAcrePkr,
      required this.totalCostForFarmPkr,
      required this.expectedYieldIncreasePct,
      required this.roiNote,
      required this.nextCheckupDays,
      this.generatedAt,
      this.district,
      this.crop})
      : _actionSteps = actionSteps,
        _medicines = medicines;

  factory _$AIAdviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIAdviceImplFromJson(json);

  @override
  final String alertUrdu;
  @override
  final String alertEnglish;
  @override
  final String diagnosis;
  @override
  final double confidencePct;
  final List<String> _actionSteps;
  @override
  List<String> get actionSteps {
    if (_actionSteps is EqualUnmodifiableListView) return _actionSteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actionSteps);
  }

  final List<Medicine> _medicines;
  @override
  List<Medicine> get medicines {
    if (_medicines is EqualUnmodifiableListView) return _medicines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medicines);
  }

  @override
  final String fertilizerAdvice;
  @override
  final String irrigationAdvice;
  @override
  final double totalCostPerAcrePkr;
  @override
  final double totalCostForFarmPkr;
  @override
  final double expectedYieldIncreasePct;
  @override
  final String roiNote;
  @override
  final int nextCheckupDays;
  @override
  final String? generatedAt;
  @override
  final String? district;
  @override
  final String? crop;

  @override
  String toString() {
    return 'AIAdvice(alertUrdu: $alertUrdu, alertEnglish: $alertEnglish, diagnosis: $diagnosis, confidencePct: $confidencePct, actionSteps: $actionSteps, medicines: $medicines, fertilizerAdvice: $fertilizerAdvice, irrigationAdvice: $irrigationAdvice, totalCostPerAcrePkr: $totalCostPerAcrePkr, totalCostForFarmPkr: $totalCostForFarmPkr, expectedYieldIncreasePct: $expectedYieldIncreasePct, roiNote: $roiNote, nextCheckupDays: $nextCheckupDays, generatedAt: $generatedAt, district: $district, crop: $crop)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIAdviceImpl &&
            (identical(other.alertUrdu, alertUrdu) ||
                other.alertUrdu == alertUrdu) &&
            (identical(other.alertEnglish, alertEnglish) ||
                other.alertEnglish == alertEnglish) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            (identical(other.confidencePct, confidencePct) ||
                other.confidencePct == confidencePct) &&
            const DeepCollectionEquality()
                .equals(other._actionSteps, _actionSteps) &&
            const DeepCollectionEquality()
                .equals(other._medicines, _medicines) &&
            (identical(other.fertilizerAdvice, fertilizerAdvice) ||
                other.fertilizerAdvice == fertilizerAdvice) &&
            (identical(other.irrigationAdvice, irrigationAdvice) ||
                other.irrigationAdvice == irrigationAdvice) &&
            (identical(other.totalCostPerAcrePkr, totalCostPerAcrePkr) ||
                other.totalCostPerAcrePkr == totalCostPerAcrePkr) &&
            (identical(other.totalCostForFarmPkr, totalCostForFarmPkr) ||
                other.totalCostForFarmPkr == totalCostForFarmPkr) &&
            (identical(
                    other.expectedYieldIncreasePct, expectedYieldIncreasePct) ||
                other.expectedYieldIncreasePct == expectedYieldIncreasePct) &&
            (identical(other.roiNote, roiNote) || other.roiNote == roiNote) &&
            (identical(other.nextCheckupDays, nextCheckupDays) ||
                other.nextCheckupDays == nextCheckupDays) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.crop, crop) || other.crop == crop));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      alertUrdu,
      alertEnglish,
      diagnosis,
      confidencePct,
      const DeepCollectionEquality().hash(_actionSteps),
      const DeepCollectionEquality().hash(_medicines),
      fertilizerAdvice,
      irrigationAdvice,
      totalCostPerAcrePkr,
      totalCostForFarmPkr,
      expectedYieldIncreasePct,
      roiNote,
      nextCheckupDays,
      generatedAt,
      district,
      crop);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AIAdviceImplCopyWith<_$AIAdviceImpl> get copyWith =>
      __$$AIAdviceImplCopyWithImpl<_$AIAdviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIAdviceImplToJson(
      this,
    );
  }
}

abstract class _AIAdvice implements AIAdvice {
  const factory _AIAdvice(
      {required final String alertUrdu,
      required final String alertEnglish,
      required final String diagnosis,
      required final double confidencePct,
      required final List<String> actionSteps,
      required final List<Medicine> medicines,
      required final String fertilizerAdvice,
      required final String irrigationAdvice,
      required final double totalCostPerAcrePkr,
      required final double totalCostForFarmPkr,
      required final double expectedYieldIncreasePct,
      required final String roiNote,
      required final int nextCheckupDays,
      final String? generatedAt,
      final String? district,
      final String? crop}) = _$AIAdviceImpl;

  factory _AIAdvice.fromJson(Map<String, dynamic> json) =
      _$AIAdviceImpl.fromJson;

  @override
  String get alertUrdu;
  @override
  String get alertEnglish;
  @override
  String get diagnosis;
  @override
  double get confidencePct;
  @override
  List<String> get actionSteps;
  @override
  List<Medicine> get medicines;
  @override
  String get fertilizerAdvice;
  @override
  String get irrigationAdvice;
  @override
  double get totalCostPerAcrePkr;
  @override
  double get totalCostForFarmPkr;
  @override
  double get expectedYieldIncreasePct;
  @override
  String get roiNote;
  @override
  int get nextCheckupDays;
  @override
  String? get generatedAt;
  @override
  String? get district;
  @override
  String? get crop;
  @override
  @JsonKey(ignore: true)
  _$$AIAdviceImplCopyWith<_$AIAdviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIAdviceRequest _$AIAdviceRequestFromJson(Map<String, dynamic> json) {
  return _AIAdviceRequest.fromJson(json);
}

/// @nodoc
mixin _$AIAdviceRequest {
  String get district => throw _privateConstructorUsedError;
  String get crop => throw _privateConstructorUsedError;
  String get province => throw _privateConstructorUsedError;
  String get season => throw _privateConstructorUsedError;
  double get farmSizeAcres => throw _privateConstructorUsedError;
  double get ndvi => throw _privateConstructorUsedError;
  double get rainfallMm => throw _privateConstructorUsedError;
  double get tempMaxC => throw _privateConstructorUsedError;
  double get soilMoisturePct => throw _privateConstructorUsedError;
  double get waterTableM => throw _privateConstructorUsedError;
  List<String> get symptoms => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AIAdviceRequestCopyWith<AIAdviceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIAdviceRequestCopyWith<$Res> {
  factory $AIAdviceRequestCopyWith(
          AIAdviceRequest value, $Res Function(AIAdviceRequest) then) =
      _$AIAdviceRequestCopyWithImpl<$Res, AIAdviceRequest>;
  @useResult
  $Res call(
      {String district,
      String crop,
      String province,
      String season,
      double farmSizeAcres,
      double ndvi,
      double rainfallMm,
      double tempMaxC,
      double soilMoisturePct,
      double waterTableM,
      List<String> symptoms,
      String language});
}

/// @nodoc
class _$AIAdviceRequestCopyWithImpl<$Res, $Val extends AIAdviceRequest>
    implements $AIAdviceRequestCopyWith<$Res> {
  _$AIAdviceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? crop = null,
    Object? province = null,
    Object? season = null,
    Object? farmSizeAcres = null,
    Object? ndvi = null,
    Object? rainfallMm = null,
    Object? tempMaxC = null,
    Object? soilMoisturePct = null,
    Object? waterTableM = null,
    Object? symptoms = null,
    Object? language = null,
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
      province: null == province
          ? _value.province
          : province // ignore: cast_nullable_to_non_nullable
              as String,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String,
      farmSizeAcres: null == farmSizeAcres
          ? _value.farmSizeAcres
          : farmSizeAcres // ignore: cast_nullable_to_non_nullable
              as double,
      ndvi: null == ndvi
          ? _value.ndvi
          : ndvi // ignore: cast_nullable_to_non_nullable
              as double,
      rainfallMm: null == rainfallMm
          ? _value.rainfallMm
          : rainfallMm // ignore: cast_nullable_to_non_nullable
              as double,
      tempMaxC: null == tempMaxC
          ? _value.tempMaxC
          : tempMaxC // ignore: cast_nullable_to_non_nullable
              as double,
      soilMoisturePct: null == soilMoisturePct
          ? _value.soilMoisturePct
          : soilMoisturePct // ignore: cast_nullable_to_non_nullable
              as double,
      waterTableM: null == waterTableM
          ? _value.waterTableM
          : waterTableM // ignore: cast_nullable_to_non_nullable
              as double,
      symptoms: null == symptoms
          ? _value.symptoms
          : symptoms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIAdviceRequestImplCopyWith<$Res>
    implements $AIAdviceRequestCopyWith<$Res> {
  factory _$$AIAdviceRequestImplCopyWith(_$AIAdviceRequestImpl value,
          $Res Function(_$AIAdviceRequestImpl) then) =
      __$$AIAdviceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String district,
      String crop,
      String province,
      String season,
      double farmSizeAcres,
      double ndvi,
      double rainfallMm,
      double tempMaxC,
      double soilMoisturePct,
      double waterTableM,
      List<String> symptoms,
      String language});
}

/// @nodoc
class __$$AIAdviceRequestImplCopyWithImpl<$Res>
    extends _$AIAdviceRequestCopyWithImpl<$Res, _$AIAdviceRequestImpl>
    implements _$$AIAdviceRequestImplCopyWith<$Res> {
  __$$AIAdviceRequestImplCopyWithImpl(
      _$AIAdviceRequestImpl _value, $Res Function(_$AIAdviceRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? crop = null,
    Object? province = null,
    Object? season = null,
    Object? farmSizeAcres = null,
    Object? ndvi = null,
    Object? rainfallMm = null,
    Object? tempMaxC = null,
    Object? soilMoisturePct = null,
    Object? waterTableM = null,
    Object? symptoms = null,
    Object? language = null,
  }) {
    return _then(_$AIAdviceRequestImpl(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      crop: null == crop
          ? _value.crop
          : crop // ignore: cast_nullable_to_non_nullable
              as String,
      province: null == province
          ? _value.province
          : province // ignore: cast_nullable_to_non_nullable
              as String,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String,
      farmSizeAcres: null == farmSizeAcres
          ? _value.farmSizeAcres
          : farmSizeAcres // ignore: cast_nullable_to_non_nullable
              as double,
      ndvi: null == ndvi
          ? _value.ndvi
          : ndvi // ignore: cast_nullable_to_non_nullable
              as double,
      rainfallMm: null == rainfallMm
          ? _value.rainfallMm
          : rainfallMm // ignore: cast_nullable_to_non_nullable
              as double,
      tempMaxC: null == tempMaxC
          ? _value.tempMaxC
          : tempMaxC // ignore: cast_nullable_to_non_nullable
              as double,
      soilMoisturePct: null == soilMoisturePct
          ? _value.soilMoisturePct
          : soilMoisturePct // ignore: cast_nullable_to_non_nullable
              as double,
      waterTableM: null == waterTableM
          ? _value.waterTableM
          : waterTableM // ignore: cast_nullable_to_non_nullable
              as double,
      symptoms: null == symptoms
          ? _value._symptoms
          : symptoms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIAdviceRequestImpl implements _AIAdviceRequest {
  const _$AIAdviceRequestImpl(
      {required this.district,
      required this.crop,
      required this.province,
      required this.season,
      required this.farmSizeAcres,
      required this.ndvi,
      required this.rainfallMm,
      required this.tempMaxC,
      required this.soilMoisturePct,
      required this.waterTableM,
      required final List<String> symptoms,
      this.language = 'en'})
      : _symptoms = symptoms;

  factory _$AIAdviceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIAdviceRequestImplFromJson(json);

  @override
  final String district;
  @override
  final String crop;
  @override
  final String province;
  @override
  final String season;
  @override
  final double farmSizeAcres;
  @override
  final double ndvi;
  @override
  final double rainfallMm;
  @override
  final double tempMaxC;
  @override
  final double soilMoisturePct;
  @override
  final double waterTableM;
  final List<String> _symptoms;
  @override
  List<String> get symptoms {
    if (_symptoms is EqualUnmodifiableListView) return _symptoms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symptoms);
  }

  @override
  @JsonKey()
  final String language;

  @override
  String toString() {
    return 'AIAdviceRequest(district: $district, crop: $crop, province: $province, season: $season, farmSizeAcres: $farmSizeAcres, ndvi: $ndvi, rainfallMm: $rainfallMm, tempMaxC: $tempMaxC, soilMoisturePct: $soilMoisturePct, waterTableM: $waterTableM, symptoms: $symptoms, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIAdviceRequestImpl &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.crop, crop) || other.crop == crop) &&
            (identical(other.province, province) ||
                other.province == province) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.farmSizeAcres, farmSizeAcres) ||
                other.farmSizeAcres == farmSizeAcres) &&
            (identical(other.ndvi, ndvi) || other.ndvi == ndvi) &&
            (identical(other.rainfallMm, rainfallMm) ||
                other.rainfallMm == rainfallMm) &&
            (identical(other.tempMaxC, tempMaxC) ||
                other.tempMaxC == tempMaxC) &&
            (identical(other.soilMoisturePct, soilMoisturePct) ||
                other.soilMoisturePct == soilMoisturePct) &&
            (identical(other.waterTableM, waterTableM) ||
                other.waterTableM == waterTableM) &&
            const DeepCollectionEquality().equals(other._symptoms, _symptoms) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      district,
      crop,
      province,
      season,
      farmSizeAcres,
      ndvi,
      rainfallMm,
      tempMaxC,
      soilMoisturePct,
      waterTableM,
      const DeepCollectionEquality().hash(_symptoms),
      language);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AIAdviceRequestImplCopyWith<_$AIAdviceRequestImpl> get copyWith =>
      __$$AIAdviceRequestImplCopyWithImpl<_$AIAdviceRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIAdviceRequestImplToJson(
      this,
    );
  }
}

abstract class _AIAdviceRequest implements AIAdviceRequest {
  const factory _AIAdviceRequest(
      {required final String district,
      required final String crop,
      required final String province,
      required final String season,
      required final double farmSizeAcres,
      required final double ndvi,
      required final double rainfallMm,
      required final double tempMaxC,
      required final double soilMoisturePct,
      required final double waterTableM,
      required final List<String> symptoms,
      final String language}) = _$AIAdviceRequestImpl;

  factory _AIAdviceRequest.fromJson(Map<String, dynamic> json) =
      _$AIAdviceRequestImpl.fromJson;

  @override
  String get district;
  @override
  String get crop;
  @override
  String get province;
  @override
  String get season;
  @override
  double get farmSizeAcres;
  @override
  double get ndvi;
  @override
  double get rainfallMm;
  @override
  double get tempMaxC;
  @override
  double get soilMoisturePct;
  @override
  double get waterTableM;
  @override
  List<String> get symptoms;
  @override
  String get language;
  @override
  @JsonKey(ignore: true)
  _$$AIAdviceRequestImplCopyWith<_$AIAdviceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
