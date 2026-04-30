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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/data/models/district.dart';
import 'package:cropsense/data/models/yield_data.dart';
import 'package:cropsense/data/models/risk_map.dart';
import 'package:cropsense/data/models/ai_advice.dart';
import 'package:cropsense/data/models/medicine.dart';
import 'package:cropsense/data/models/stats_model.dart';

// ─────────────────────────────────────────────────────────────────────────
// APP EXCEPTION
// A custom exception class that converts raw HTTP/network errors into
// messages a user (or developer) can actually understand.
// ─────────────────────────────────────────────────────────────────────────
class AppException implements Exception {
  final String message;       // User-friendly message shown in the UI
  final String? technical;    // Technical detail for debugging (not shown to user)
  final int? statusCode;      // HTTP status code if available

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
      methodCount: 0,       // Don't show stack trace on every log
      errorMethodCount: 5,  // Show 5 stack frames on errors
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  ApiService() {
    // Read the base URL from .env file.
    // During development this is http://localhost:8000
    // After deploying backend to Render, we update .env with the Render URL.
    final baseUrl = dotenv.env['CROPSENSE_API_URL'] ?? 'http://localhost:8000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,

        // How long to wait for a response before giving up.
        // 30 seconds is generous — Render free tier can be slow to wake up.
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),

        // Tell the backend we're sending and expecting JSON
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Only add request logging in debug mode (not in production builds)
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            _logger.d('→ ${options.method} ${options.path}');
            if (options.data != null) {
              _logger.d('  Body: ${jsonEncode(options.data)}');
            }
            handler.next(options); // Continue the request
          },
          onResponse: (response, handler) {
            _logger.i('← ${response.statusCode} ${response.requestOptions.path}');
            handler.next(response);
          },
          onError: (error, handler) {
            _logger.e('✗ ${error.requestOptions.path}: ${error.message}');
            handler.next(error);
          },
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // ERROR CONVERTER
  // Takes any DioException and returns an AppException with a friendly
  // message. Called in every catch block below.
  // ─────────────────────────────────────────────────────────────────────
  AppException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(
          message: 'Connection timed out. Please check your internet and try again.',
          technical: 'Timeout',
        );

      case DioExceptionType.connectionError:
        return const AppException(
          message: 'Cannot reach the server. Make sure the backend is running.',
          technical: 'ConnectionError',
        );

      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        switch (code) {
          case 400:
            return AppException(
              message: 'Invalid request. Please check your inputs.',
              statusCode: code,
            );
          case 404:
            return AppException(
              message: 'Data not found for the selected district or crop.',
              statusCode: code,
            );
          case 500:
            return AppException(
              message: 'Server error. Please try again in a few minutes.',
              statusCode: code,
            );
          default:
            return AppException(
              message: 'Unexpected server response (code $code).',
              statusCode: code,
            );
        }

      default:
        return AppException(
          message: 'Something went wrong. Please try again.',
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
      final response = await _dio.get(ApiEndpoints.districts);

      // The backend returns: { "districts": [...] }
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
  Future<RiskMapResponse> getRiskMap() async {
    try {
      final response = await _dio.get(ApiEndpoints.riskMap);
      return RiskMapResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
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
      final response = await _dio.get(
        ApiEndpoints.yieldData(district, crop),
      );
      return YieldDataResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
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
      final response = await _dio.get(ApiEndpoints.stats(district));
      return StatsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
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
  Future<AIAdvice> getAIAdvice({
    required AIAdviceRequest request,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.aiAdvise,
        // .toJson() converts our typed Dart object into a JSON map
        data: request.toJson(),
      );
      return AIAdvice.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}