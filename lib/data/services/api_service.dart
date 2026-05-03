// lib/data/services/api_service.dart
//
// CropSense API Service — the single HTTP client for all backend calls.
// ─────────────────────────────────────────────────────────────────────────
// Built on Dio (a powerful HTTP library for Dart/Flutter).
// All screens and providers call methods on this class — never use
// raw http or Dio directly elsewhere in the project.
//
// How it works:
//   1. ApiService is created once (singleton via Riverpod provider)
//   2. Every method makes a typed HTTP call to FastAPI
//   3. Errors are caught and converted to AppException (user-friendly)
//   4. All requests/responses are logged in debug mode
//
// Import with: import 'package:cropsense/data/services/api_service.dart';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:cropsense/config/app_config.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/data/models/district.dart';
import 'package:cropsense/data/models/yield_data.dart';
import 'package:cropsense/data/models/risk_map.dart';
import 'package:cropsense/data/models/ai_advice.dart';
import 'package:cropsense/data/models/stats_model.dart';
import 'package:cropsense/data/models/weather_data.dart';
import 'package:cropsense/data/models/comparison_model.dart';

// ─────────────────────────────────────────────────────────────────────────
// APP EXCEPTION
// A custom exception class that converts raw HTTP/network errors into
// messages a user (or developer) can actually understand.
// ─────────────────────────────────────────────────────────────────────────
class AppException implements Exception {
  final String message; // User-friendly message shown in the UI
  final String? technical; // Technical detail for debugging (not shown to user)
  final int? statusCode; // HTTP status code if available

  const AppException({
    required this.message,
    this.technical,
    this.statusCode,
  });

  @override
  String toString() => 'AppException: $message (code: $statusCode)';
}

// ─────────────────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────────────────
class ApiService {
  late final Dio _dio;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Don't show stack trace on every log
      errorMethodCount: 5, // Show 5 stack frames on errors
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  ApiService() {
    final baseUrl = AppConfig.apiBaseUrl;
    if (kDebugMode) {
      debugPrint('API base URL: $baseUrl');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint(
              '→ ${options.method} ${options.baseUrl}${options.path}',
            );
            if (options.data != null) {
              _logger.d('  Body: ${jsonEncode(options.data)}');
            }
            handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              '← ${response.statusCode} ${response.requestOptions.path}',
            );
            handler.next(response);
          },
          onError: (error, handler) {
            debugPrint(
              '✗ ${error.requestOptions.baseUrl}${error.requestOptions.path}: ${error.message}',
            );
            handler.next(error);
          },
        ),
      );
    }
  }

  // Retry helper — waits 2 s then retries once on any error.
  Future<Response<dynamic>> _getWithRetry(String path) async {
    try {
      return await _dio.get(path);
    } catch (_) {
      await Future.delayed(const Duration(seconds: 2));
      return await _dio.get(path);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // ERROR CONVERTER
  // Extracts the FastAPI "detail" string from a JSON response body.
  // ─────────────────────────────────────────────────────────────────────
  String? _apiDetail(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        // Pydantic validation errors: [{loc:[...], msg:'...'}]
        final parts = detail.map((item) {
          if (item is Map) {
            final loc = item['loc'];
            final field = (loc is List && loc.isNotEmpty)
                ? loc.last.toString().replaceAll('_', ' ')
                : 'field';
            final msg = item['msg']?.toString() ?? 'invalid';
            return '$field: $msg';
          }
          return item.toString();
        }).toList();
        return parts.join('; ');
      }
    }
    return null;
  }

  AppException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(
          message:
              'Connection timed out while contacting the CropSense backend. Check your internet connection and backend URL.',
          technical: 'Timeout',
        );

      case DioExceptionType.connectionError:
        return AppException(
          message:
              'Cannot reach the CropSense backend at ${AppConfig.apiBaseUrl}.\n\n'
              'The backend may be offline, the API URL may be wrong, or CORS may be blocking the request.\n\n'
              'For local development, start it with:\n'
              '  cd backend\n'
              '  python -m uvicorn app.main:app --reload --port 8000',
          technical: 'ConnectionError',
        );

      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final detail = _apiDetail(e.response?.data);
        switch (code) {
          case 400:
            return AppException(
              message: detail ?? 'Invalid request. Please check your inputs.',
              statusCode: code,
            );
          case 401:
            return AppException(
              message: detail ??
                  'Incorrect email/username or password. Please try again.',
              statusCode: code,
            );
          case 409:
            return AppException(
              message: detail ??
                  'An account with this email or username already exists.',
              statusCode: code,
            );
          case 422:
            return AppException(
              message: detail ?? 'Please fill all required fields correctly.',
              statusCode: code,
            );
          case 404:
            return AppException(
              message:
                  detail ?? 'Data not found for the selected district or crop.',
              statusCode: code,
            );
          case 500:
            return AppException(
              message:
                  detail ?? 'Server error. Please try again in a few minutes.',
              statusCode: code,
            );
          case 503:
            return AppException(
              message: 'The backend database is not set up.\n\n'
                  'Add this to backend/.env and restart the server:\n'
                  '  DATABASE_URL=sqlite:///./cropsense_dev.db',
              statusCode: code,
            );
          default:
            return AppException(
              message: detail ?? 'Unexpected server response (code $code).',
              statusCode: code,
            );
        }

      default:
        return AppException(
          message:
              'Something went wrong while contacting the CropSense backend. Please check your connection and try again.',
          technical: e.message,
        );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // GET /api/districts
  // Returns all 36 Pakistan districts with current readings.
  // Called by: districtProvider on app startup.
  // ─────────────────────────────────────────────────────────────────────
  Future<List<District>> getDistricts() async {
    try {
      final response = await _getWithRetry(ApiEndpoints.districts);
      final List<dynamic> raw = response.data['districts'] as List<dynamic>;
      return raw
          .map((json) => District.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // GET /api/risk-map
  // Returns risk levels for all districts (used to color the map).
  // Called by: mapProvider.
  // ─────────────────────────────────────────────────────────────────────
  Future<RiskMapResponse> getRiskMap({
    String crop = 'wheat',
    int year = 2023,
  }) async {
    try {
      final response = await _getWithRetry(ApiEndpoints.riskMapFor(crop, year));
      return RiskMapResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // GET /api/yield/{district}/{crop}
  // Returns historical yield + climate data for one district/crop pair.
  // Called by: yieldProvider (Analytics screen charts).
  // ─────────────────────────────────────────────────────────────────────
  Future<YieldDataResponse> getYieldData({
    required String district,
    required String crop,
  }) async {
    try {
      final response =
          await _getWithRetry(ApiEndpoints.yieldData(district, crop));
      return YieldDataResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // GET /api/ndvi-timeseries/{district}
  // Returns NDVI readings over time for one district.
  // Returns raw list because we just need (year, ndvi) pairs for charts.
  // ─────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getNdviTimeseries({
    required String district,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.ndviTimeseries(district),
      );
      final List<dynamic> raw = response.data['data'] as List<dynamic>;
      return raw.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // GET /api/stats/{district}
  // Returns full statistical analysis for all crops in one district.
  // Called by: Analytics screen.
  // ─────────────────────────────────────────────────────────────────────
  Future<StatsResponse> getStats({required String district}) async {
    try {
      final response = await _getWithRetry(ApiEndpoints.stats(district));
      return StatsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // GET /api/provinces
  // Returns province-level summary data for the Dashboard cards.
  // ─────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProvinces() async {
    try {
      final response = await _dio.get(ApiEndpoints.provinces);
      final List<dynamic> raw = response.data['provinces'] as List<dynamic>;
      return raw.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // POST /api/predict
  // Sends field conditions → gets 14-day yield prediction from ML model.
  // Called by: AI Advisor screen (before the full AI advice call).
  // ─────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> predict({
    required String district,
    required String crop,
    required double ndvi,
    required double rainfallMm,
    required double tempMaxC,
    required double soilMoisturePct,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.predict,
        data: {
          'district': district,
          'crop': crop,
          'ndvi': ndvi,
          'rainfall_mm': rainfallMm,
          'temp_max_c': tempMaxC,
          'soil_moisture_pct': soilMoisturePct,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // POST /api/ai-advise
  // The main AI call — sends farm conditions → gets full Grok advisory.
  // This is the most important endpoint in CropSense.
  // Called by: AI Advisor screen when farmer taps "Analyze with AI".
  // ─────────────────────────────────────────────────────────────────────
  Future<WeatherData> getWeather({required String district}) async {
    try {
      final response = await _dio.get(ApiEndpoints.weather(district));
      final raw = response.data as Map<String, dynamic>;
      return WeatherData(
        district: raw['district'] as String? ?? district,
        temperature: (raw['temperature'] as num).toDouble(),
        rainfall30day: (raw['rainfall_30day'] as num).toDouble(),
        humidity: (raw['humidity'] as num).toDouble(),
        windSpeed: (raw['wind_speed'] as num).toDouble(),
        tempMaxForecast: (raw['temp_max_forecast'] as num).toDouble(),
        tempMinForecast: (raw['temp_min_forecast'] as num).toDouble(),
        evapotranspiration: (raw['evapotranspiration'] as num).toDouble(),
        heatStressAlert: raw['heat_stress_alert'] as bool? ?? false,
        droughtAlert: raw['drought_alert'] as bool? ?? false,
        ndviEstimate: (raw['ndvi_estimate'] as num).toDouble(),
        dataSource: raw['data_source'] as String? ?? 'Open-Meteo',
        fetchedAt: raw['fetched_at'] as String? ?? '',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComparisonModel> getComparison({
    required String district1,
    required String district2,
    required String crop,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.compare(district1, district2, crop),
      );
      return ComparisonModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AIAdvice> getAIAdvice({
    required AIAdviceRequest request,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.aiAdvise,
        data: request.toJson(),
      );
      return AIAdvice.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required List<Map<String, dynamic>> messages,
    required String district,
    required String crop,
    required Map<String, dynamic> context,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'messages': messages,
          'district': district,
          'crop': crop,
          'context': context,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAnalyticsSummary({
    required String district,
    String crop = 'all',
    String season = 'all',
    int startYear = 2005,
    int endYear = 2023,
    String soilType = 'loam',
    double farmAcres = 5.0,
  }) async {
    try {
      final query = <String, dynamic>{
        'farm_acres': farmAcres,
        'crop': crop,
        'season': season,
        'start_year': startYear,
        'end_year': endYear,
        'soil_type': soilType,
      }.entries.map((e) {
        return '${Uri.encodeQueryComponent(e.key)}='
            '${Uri.encodeQueryComponent(e.value.toString())}';
      }).join('&');

      final response = await _getWithRetry(
        '/api/analytics/summary/$district?$query',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> analyzeCropImage({
    required String imageBase64,
    required String district,
    required String crop,
  }) async {
    try {
      final response = await _dio.post(
        '/api/analyze-image',
        data: {
          'imageBase64': imageBase64,
          'district': district,
          'crop': crop,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFuturePrediction({
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.futurePrediction,
        data: request,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Options _auth(String token) => Options(
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {'email': email, 'username': username, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'identifier': identifier, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> listFields({required String token}) async {
    try {
      final response = await _dio.get(
        '/api/field-management/fields',
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createField({
    required String token,
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await _dio.post(
        '/api/field-management/fields',
        data: request,
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFieldDetail({
    required String token,
    required String fieldId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/field-management/fields/$fieldId',
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateField({
    required String token,
    required String fieldId,
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await _dio.put(
        '/api/field-management/fields/$fieldId',
        data: request,
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteField({
    required String token,
    required String fieldId,
  }) async {
    try {
      await _dio.delete(
        '/api/field-management/fields/$fieldId',
        options: _auth(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addFieldLog({
    required String token,
    required String fieldId,
    required String type,
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await _dio.post(
        '/api/field-management/fields/$fieldId/$type',
        data: request,
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFieldAnalytics({
    required String token,
    required String fieldId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/field-management/fields/$fieldId/analytics',
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFieldAiAdvice({
    required String token,
    required String fieldId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/field-management/fields/$fieldId/ai-cost-advice',
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFieldReport({
    required String token,
    required String fieldId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/field-management/fields/$fieldId/report',
        options: _auth(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
