// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) {
  return _WeatherData.fromJson(json);
}

/// @nodoc
mixin _$WeatherData {
  String get district => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  double get rainfall30day => throw _privateConstructorUsedError;
  double get humidity => throw _privateConstructorUsedError;
  double get windSpeed => throw _privateConstructorUsedError;
  double get tempMaxForecast => throw _privateConstructorUsedError;
  double get tempMinForecast => throw _privateConstructorUsedError;
  double get evapotranspiration => throw _privateConstructorUsedError;
  bool get heatStressAlert => throw _privateConstructorUsedError;
  bool get droughtAlert => throw _privateConstructorUsedError;
  double get ndviEstimate => throw _privateConstructorUsedError;
  String get dataSource => throw _privateConstructorUsedError;
  String get fetchedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeatherDataCopyWith<WeatherData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherDataCopyWith<$Res> {
  factory $WeatherDataCopyWith(
          WeatherData value, $Res Function(WeatherData) then) =
      _$WeatherDataCopyWithImpl<$Res, WeatherData>;
  @useResult
  $Res call(
      {String district,
      double temperature,
      double rainfall30day,
      double humidity,
      double windSpeed,
      double tempMaxForecast,
      double tempMinForecast,
      double evapotranspiration,
      bool heatStressAlert,
      bool droughtAlert,
      double ndviEstimate,
      String dataSource,
      String fetchedAt});
}

/// @nodoc
class _$WeatherDataCopyWithImpl<$Res, $Val extends WeatherData>
    implements $WeatherDataCopyWith<$Res> {
  _$WeatherDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? temperature = null,
    Object? rainfall30day = null,
    Object? humidity = null,
    Object? windSpeed = null,
    Object? tempMaxForecast = null,
    Object? tempMinForecast = null,
    Object? evapotranspiration = null,
    Object? heatStressAlert = null,
    Object? droughtAlert = null,
    Object? ndviEstimate = null,
    Object? dataSource = null,
    Object? fetchedAt = null,
  }) {
    return _then(_value.copyWith(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      rainfall30day: null == rainfall30day
          ? _value.rainfall30day
          : rainfall30day // ignore: cast_nullable_to_non_nullable
              as double,
      humidity: null == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double,
      windSpeed: null == windSpeed
          ? _value.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      tempMaxForecast: null == tempMaxForecast
          ? _value.tempMaxForecast
          : tempMaxForecast // ignore: cast_nullable_to_non_nullable
              as double,
      tempMinForecast: null == tempMinForecast
          ? _value.tempMinForecast
          : tempMinForecast // ignore: cast_nullable_to_non_nullable
              as double,
      evapotranspiration: null == evapotranspiration
          ? _value.evapotranspiration
          : evapotranspiration // ignore: cast_nullable_to_non_nullable
              as double,
      heatStressAlert: null == heatStressAlert
          ? _value.heatStressAlert
          : heatStressAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      droughtAlert: null == droughtAlert
          ? _value.droughtAlert
          : droughtAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      ndviEstimate: null == ndviEstimate
          ? _value.ndviEstimate
          : ndviEstimate // ignore: cast_nullable_to_non_nullable
              as double,
      dataSource: null == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeatherDataImplCopyWith<$Res>
    implements $WeatherDataCopyWith<$Res> {
  factory _$$WeatherDataImplCopyWith(
          _$WeatherDataImpl value, $Res Function(_$WeatherDataImpl) then) =
      __$$WeatherDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String district,
      double temperature,
      double rainfall30day,
      double humidity,
      double windSpeed,
      double tempMaxForecast,
      double tempMinForecast,
      double evapotranspiration,
      bool heatStressAlert,
      bool droughtAlert,
      double ndviEstimate,
      String dataSource,
      String fetchedAt});
}

/// @nodoc
class __$$WeatherDataImplCopyWithImpl<$Res>
    extends _$WeatherDataCopyWithImpl<$Res, _$WeatherDataImpl>
    implements _$$WeatherDataImplCopyWith<$Res> {
  __$$WeatherDataImplCopyWithImpl(
      _$WeatherDataImpl _value, $Res Function(_$WeatherDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? district = null,
    Object? temperature = null,
    Object? rainfall30day = null,
    Object? humidity = null,
    Object? windSpeed = null,
    Object? tempMaxForecast = null,
    Object? tempMinForecast = null,
    Object? evapotranspiration = null,
    Object? heatStressAlert = null,
    Object? droughtAlert = null,
    Object? ndviEstimate = null,
    Object? dataSource = null,
    Object? fetchedAt = null,
  }) {
    return _then(_$WeatherDataImpl(
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      rainfall30day: null == rainfall30day
          ? _value.rainfall30day
          : rainfall30day // ignore: cast_nullable_to_non_nullable
              as double,
      humidity: null == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double,
      windSpeed: null == windSpeed
          ? _value.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      tempMaxForecast: null == tempMaxForecast
          ? _value.tempMaxForecast
          : tempMaxForecast // ignore: cast_nullable_to_non_nullable
              as double,
      tempMinForecast: null == tempMinForecast
          ? _value.tempMinForecast
          : tempMinForecast // ignore: cast_nullable_to_non_nullable
              as double,
      evapotranspiration: null == evapotranspiration
          ? _value.evapotranspiration
          : evapotranspiration // ignore: cast_nullable_to_non_nullable
              as double,
      heatStressAlert: null == heatStressAlert
          ? _value.heatStressAlert
          : heatStressAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      droughtAlert: null == droughtAlert
          ? _value.droughtAlert
          : droughtAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      ndviEstimate: null == ndviEstimate
          ? _value.ndviEstimate
          : ndviEstimate // ignore: cast_nullable_to_non_nullable
              as double,
      dataSource: null == dataSource
          ? _value.dataSource
          : dataSource // ignore: cast_nullable_to_non_nullable
              as String,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherDataImpl implements _WeatherData {
  const _$WeatherDataImpl(
      {required this.district,
      required this.temperature,
      required this.rainfall30day,
      required this.humidity,
      required this.windSpeed,
      required this.tempMaxForecast,
      required this.tempMinForecast,
      required this.evapotranspiration,
      required this.heatStressAlert,
      required this.droughtAlert,
      required this.ndviEstimate,
      this.dataSource = 'Open-Meteo',
      this.fetchedAt = ''});

  factory _$WeatherDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherDataImplFromJson(json);

  @override
  final String district;
  @override
  final double temperature;
  @override
  final double rainfall30day;
  @override
  final double humidity;
  @override
  final double windSpeed;
  @override
  final double tempMaxForecast;
  @override
  final double tempMinForecast;
  @override
  final double evapotranspiration;
  @override
  final bool heatStressAlert;
  @override
  final bool droughtAlert;
  @override
  final double ndviEstimate;
  @override
  @JsonKey()
  final String dataSource;
  @override
  @JsonKey()
  final String fetchedAt;

  @override
  String toString() {
    return 'WeatherData(district: $district, temperature: $temperature, rainfall30day: $rainfall30day, humidity: $humidity, windSpeed: $windSpeed, tempMaxForecast: $tempMaxForecast, tempMinForecast: $tempMinForecast, evapotranspiration: $evapotranspiration, heatStressAlert: $heatStressAlert, droughtAlert: $droughtAlert, ndviEstimate: $ndviEstimate, dataSource: $dataSource, fetchedAt: $fetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherDataImpl &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.rainfall30day, rainfall30day) ||
                other.rainfall30day == rainfall30day) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.tempMaxForecast, tempMaxForecast) ||
                other.tempMaxForecast == tempMaxForecast) &&
            (identical(other.tempMinForecast, tempMinForecast) ||
                other.tempMinForecast == tempMinForecast) &&
            (identical(other.evapotranspiration, evapotranspiration) ||
                other.evapotranspiration == evapotranspiration) &&
            (identical(other.heatStressAlert, heatStressAlert) ||
                other.heatStressAlert == heatStressAlert) &&
            (identical(other.droughtAlert, droughtAlert) ||
                other.droughtAlert == droughtAlert) &&
            (identical(other.ndviEstimate, ndviEstimate) ||
                other.ndviEstimate == ndviEstimate) &&
            (identical(other.dataSource, dataSource) ||
                other.dataSource == dataSource) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      district,
      temperature,
      rainfall30day,
      humidity,
      windSpeed,
      tempMaxForecast,
      tempMinForecast,
      evapotranspiration,
      heatStressAlert,
      droughtAlert,
      ndviEstimate,
      dataSource,
      fetchedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      __$$WeatherDataImplCopyWithImpl<_$WeatherDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherDataImplToJson(
      this,
    );
  }
}

abstract class _WeatherData implements WeatherData {
  const factory _WeatherData(
      {required final String district,
      required final double temperature,
      required final double rainfall30day,
      required final double humidity,
      required final double windSpeed,
      required final double tempMaxForecast,
      required final double tempMinForecast,
      required final double evapotranspiration,
      required final bool heatStressAlert,
      required final bool droughtAlert,
      required final double ndviEstimate,
      final String dataSource,
      final String fetchedAt}) = _$WeatherDataImpl;

  factory _WeatherData.fromJson(Map<String, dynamic> json) =
      _$WeatherDataImpl.fromJson;

  @override
  String get district;
  @override
  double get temperature;
  @override
  double get rainfall30day;
  @override
  double get humidity;
  @override
  double get windSpeed;
  @override
  double get tempMaxForecast;
  @override
  double get tempMinForecast;
  @override
  double get evapotranspiration;
  @override
  bool get heatStressAlert;
  @override
  bool get droughtAlert;
  @override
  double get ndviEstimate;
  @override
  String get dataSource;
  @override
  String get fetchedAt;
  @override
  @JsonKey(ignore: true)
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
