// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Medicine _$MedicineFromJson(Map<String, dynamic> json) {
  return _Medicine.fromJson(json);
}

/// @nodoc
mixin _$Medicine {
// Brand name sold in Pakistani markets: e.g., "Topsin-M 70 WP"
  String get name =>
      throw _privateConstructorUsedError; // Category: fungicide / pesticide / herbicide / fertilizer / growth_reg
  MedicineType get type =>
      throw _privateConstructorUsedError; // Chemical/active ingredient: e.g., "Thiophanate-methyl 70%"
  String get activeIngredient =>
      throw _privateConstructorUsedError; // Application dose per acre: e.g., "250g per acre" or "500ml per acre"
  String get dose =>
      throw _privateConstructorUsedError; // Estimated price per acre in Pakistani Rupees
  double get pricePerAcrePkr =>
      throw _privateConstructorUsedError; // How urgently this needs to be applied
  MedicineUrgency get urgency =>
      throw _privateConstructorUsedError; // What disease/problem this treats: e.g., "Wheat rust (Puccinia striiformis)"
  String get purpose =>
      throw _privateConstructorUsedError; // Where to buy in Pakistan: e.g., "Any agri store in Faisalabad grain market"
  String get whereToBuy =>
      throw _privateConstructorUsedError; // Optional note: mixing instructions, safety warnings, etc.
  String? get applicationNote => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicineCopyWith<Medicine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicineCopyWith<$Res> {
  factory $MedicineCopyWith(Medicine value, $Res Function(Medicine) then) =
      _$MedicineCopyWithImpl<$Res, Medicine>;
  @useResult
  $Res call(
      {String name,
      MedicineType type,
      String activeIngredient,
      String dose,
      double pricePerAcrePkr,
      MedicineUrgency urgency,
      String purpose,
      String whereToBuy,
      String? applicationNote});
}

/// @nodoc
class _$MedicineCopyWithImpl<$Res, $Val extends Medicine>
    implements $MedicineCopyWith<$Res> {
  _$MedicineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? activeIngredient = null,
    Object? dose = null,
    Object? pricePerAcrePkr = null,
    Object? urgency = null,
    Object? purpose = null,
    Object? whereToBuy = null,
    Object? applicationNote = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MedicineType,
      activeIngredient: null == activeIngredient
          ? _value.activeIngredient
          : activeIngredient // ignore: cast_nullable_to_non_nullable
              as String,
      dose: null == dose
          ? _value.dose
          : dose // ignore: cast_nullable_to_non_nullable
              as String,
      pricePerAcrePkr: null == pricePerAcrePkr
          ? _value.pricePerAcrePkr
          : pricePerAcrePkr // ignore: cast_nullable_to_non_nullable
              as double,
      urgency: null == urgency
          ? _value.urgency
          : urgency // ignore: cast_nullable_to_non_nullable
              as MedicineUrgency,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      whereToBuy: null == whereToBuy
          ? _value.whereToBuy
          : whereToBuy // ignore: cast_nullable_to_non_nullable
              as String,
      applicationNote: freezed == applicationNote
          ? _value.applicationNote
          : applicationNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MedicineImplCopyWith<$Res>
    implements $MedicineCopyWith<$Res> {
  factory _$$MedicineImplCopyWith(
          _$MedicineImpl value, $Res Function(_$MedicineImpl) then) =
      __$$MedicineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      MedicineType type,
      String activeIngredient,
      String dose,
      double pricePerAcrePkr,
      MedicineUrgency urgency,
      String purpose,
      String whereToBuy,
      String? applicationNote});
}

/// @nodoc
class __$$MedicineImplCopyWithImpl<$Res>
    extends _$MedicineCopyWithImpl<$Res, _$MedicineImpl>
    implements _$$MedicineImplCopyWith<$Res> {
  __$$MedicineImplCopyWithImpl(
      _$MedicineImpl _value, $Res Function(_$MedicineImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? activeIngredient = null,
    Object? dose = null,
    Object? pricePerAcrePkr = null,
    Object? urgency = null,
    Object? purpose = null,
    Object? whereToBuy = null,
    Object? applicationNote = freezed,
  }) {
    return _then(_$MedicineImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MedicineType,
      activeIngredient: null == activeIngredient
          ? _value.activeIngredient
          : activeIngredient // ignore: cast_nullable_to_non_nullable
              as String,
      dose: null == dose
          ? _value.dose
          : dose // ignore: cast_nullable_to_non_nullable
              as String,
      pricePerAcrePkr: null == pricePerAcrePkr
          ? _value.pricePerAcrePkr
          : pricePerAcrePkr // ignore: cast_nullable_to_non_nullable
              as double,
      urgency: null == urgency
          ? _value.urgency
          : urgency // ignore: cast_nullable_to_non_nullable
              as MedicineUrgency,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      whereToBuy: null == whereToBuy
          ? _value.whereToBuy
          : whereToBuy // ignore: cast_nullable_to_non_nullable
              as String,
      applicationNote: freezed == applicationNote
          ? _value.applicationNote
          : applicationNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicineImpl implements _Medicine {
  const _$MedicineImpl(
      {required this.name,
      required this.type,
      required this.activeIngredient,
      required this.dose,
      required this.pricePerAcrePkr,
      required this.urgency,
      required this.purpose,
      required this.whereToBuy,
      this.applicationNote});

  factory _$MedicineImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicineImplFromJson(json);

// Brand name sold in Pakistani markets: e.g., "Topsin-M 70 WP"
  @override
  final String name;
// Category: fungicide / pesticide / herbicide / fertilizer / growth_reg
  @override
  final MedicineType type;
// Chemical/active ingredient: e.g., "Thiophanate-methyl 70%"
  @override
  final String activeIngredient;
// Application dose per acre: e.g., "250g per acre" or "500ml per acre"
  @override
  final String dose;
// Estimated price per acre in Pakistani Rupees
  @override
  final double pricePerAcrePkr;
// How urgently this needs to be applied
  @override
  final MedicineUrgency urgency;
// What disease/problem this treats: e.g., "Wheat rust (Puccinia striiformis)"
  @override
  final String purpose;
// Where to buy in Pakistan: e.g., "Any agri store in Faisalabad grain market"
  @override
  final String whereToBuy;
// Optional note: mixing instructions, safety warnings, etc.
  @override
  final String? applicationNote;

  @override
  String toString() {
    return 'Medicine(name: $name, type: $type, activeIngredient: $activeIngredient, dose: $dose, pricePerAcrePkr: $pricePerAcrePkr, urgency: $urgency, purpose: $purpose, whereToBuy: $whereToBuy, applicationNote: $applicationNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicineImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.activeIngredient, activeIngredient) ||
                other.activeIngredient == activeIngredient) &&
            (identical(other.dose, dose) || other.dose == dose) &&
            (identical(other.pricePerAcrePkr, pricePerAcrePkr) ||
                other.pricePerAcrePkr == pricePerAcrePkr) &&
            (identical(other.urgency, urgency) || other.urgency == urgency) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.whereToBuy, whereToBuy) ||
                other.whereToBuy == whereToBuy) &&
            (identical(other.applicationNote, applicationNote) ||
                other.applicationNote == applicationNote));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, type, activeIngredient,
      dose, pricePerAcrePkr, urgency, purpose, whereToBuy, applicationNote);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      __$$MedicineImplCopyWithImpl<_$MedicineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicineImplToJson(
      this,
    );
  }
}

abstract class _Medicine implements Medicine {
  const factory _Medicine(
      {required final String name,
      required final MedicineType type,
      required final String activeIngredient,
      required final String dose,
      required final double pricePerAcrePkr,
      required final MedicineUrgency urgency,
      required final String purpose,
      required final String whereToBuy,
      final String? applicationNote}) = _$MedicineImpl;

  factory _Medicine.fromJson(Map<String, dynamic> json) =
      _$MedicineImpl.fromJson;

  @override // Brand name sold in Pakistani markets: e.g., "Topsin-M 70 WP"
  String get name;
  @override // Category: fungicide / pesticide / herbicide / fertilizer / growth_reg
  MedicineType get type;
  @override // Chemical/active ingredient: e.g., "Thiophanate-methyl 70%"
  String get activeIngredient;
  @override // Application dose per acre: e.g., "250g per acre" or "500ml per acre"
  String get dose;
  @override // Estimated price per acre in Pakistani Rupees
  double get pricePerAcrePkr;
  @override // How urgently this needs to be applied
  MedicineUrgency get urgency;
  @override // What disease/problem this treats: e.g., "Wheat rust (Puccinia striiformis)"
  String get purpose;
  @override // Where to buy in Pakistan: e.g., "Any agri store in Faisalabad grain market"
  String get whereToBuy;
  @override // Optional note: mixing instructions, safety warnings, etc.
  String? get applicationNote;
  @override
  @JsonKey(ignore: true)
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
