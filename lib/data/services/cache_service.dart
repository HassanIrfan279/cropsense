// lib/data/services/cache_service.dart
//
// CropSense Cache Service — offline-first local storage using Hive.
// ─────────────────────────────────────────────────────────────────────────
// Hive is a key-value store. We store JSON strings (not Dart objects)
// because that's simpler and avoids Hive type adapter complexity.
//
// Every cached item is stored with a timestamp so we can check if it's
// still "fresh" before deciding whether to fetch from the API again.
//
// Storage locations (automatic — Hive handles this):
//   Web:     Browser IndexedDB (survives page refresh, cleared on logout)
//   Desktop: %APPDATA%\cropsense\ on Windows, ~/Library on macOS
//
// Import with: import 'package:cropsense/data/services/cache_service.dart';

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:cropsense/core/constants.dart';

// ─────────────────────────────────────────────────────────────────────────
// CACHED ITEM WRAPPER
// Every value stored in Hive is wrapped in this class so we know
// exactly when it was saved and whether it's still fresh.
// ─────────────────────────────────────────────────────────────────────────
class CachedItem {
  final dynamic data;           // The actual data (JSON-decoded)
  final DateTime cachedAt;      // When it was stored

  CachedItem({required this.data, required this.cachedAt});

  // Convert to a map so we can JSON-encode it for Hive storage
  Map<String, dynamic> toMap() => {
    'data': data,
    'cachedAt': cachedAt.toIso8601String(),
  };

  // Reconstruct from a map when reading from Hive
  factory CachedItem.fromMap(Map<String, dynamic> map) => CachedItem(
    data: map['data'],
    cachedAt: DateTime.parse(map['cachedAt'] as String),
  );

  // Returns true if this item is still within the allowed age
  bool isFresh(Duration maxAge) {
    return DateTime.now().difference(cachedAt) < maxAge;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// CACHE SERVICE
// ─────────────────────────────────────────────────────────────────────────
class CacheService {
  // Hive box name — think of this like a table name in a database
  static const String _boxName = 'cropsense_cache';

  late Box _box;
  bool _isInitialized = false;

  final _logger = Logger();

  // ── Initialize ──────────────────────────────────────────────────────
  // Must be called once before using any other method.
  // Called from main.dart before runApp().
  Future<void> init() async {
    if (_isInitialized) return;

    // initFlutter() handles platform differences automatically:
    //   Web → uses IndexedDB
    //   Desktop/Mobile → uses file system
    await Hive.initFlutter();

    // Open our named box (creates it if it doesn't exist)
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;

    _logger.i('CacheService initialized. '
        'Stored keys: ${_box.keys.length}');
  }

  // ── WRITE ────────────────────────────────────────────────────────────
  // Store any data under a key with the current timestamp.
  // The data is JSON-encoded as a string for reliable storage.
  Future<void> set(String key, dynamic data) async {
    try {
      final item = CachedItem(data: data, cachedAt: DateTime.now());
      // jsonEncode converts Maps/Lists/primitives to a JSON string
      await _box.put(key, jsonEncode(item.toMap()));
      _logger.d('Cache SET: $key');
    } catch (e) {
      // Cache writes should never crash the app — just log and continue
      _logger.w('Cache write failed for key "$key": $e');
    }
  }

  // ── READ ─────────────────────────────────────────────────────────────
  // Retrieve data for a key. Returns null if:
  //   - Key doesn't exist (never cached)
  //   - Data is older than maxAge (stale)
  dynamic get(String key, Duration maxAge) {
    try {
      final raw = _box.get(key) as String?;
      if (raw == null) return null; // Never cached

      // Decode the JSON string back to a map
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final item = CachedItem.fromMap(map);

      if (!item.isFresh(maxAge)) {
        _logger.d('Cache STALE: $key');
        return null; // Too old — caller will fetch from API
      }

      _logger.d('Cache HIT: $key');
      return item.data;
    } catch (e) {
      _logger.w('Cache read failed for key "$key": $e');
      return null;
    }
  }

  // ── DELETE ───────────────────────────────────────────────────────────
  // Remove a specific cached item (e.g., force-refresh one district)
  Future<void> delete(String key) async {
    await _box.delete(key);
    _logger.d('Cache DELETE: $key');
  }

  // ── CLEAR ALL ────────────────────────────────────────────────────────
  // Wipe everything — useful for logout or manual refresh button
  Future<void> clearAll() async {
    await _box.clear();
    _logger.i('Cache CLEARED — all items removed');
  }

  // ── CONVENIENCE METHODS ──────────────────────────────────────────────
  // These wrap the generic get/set with the correct keys and durations
  // defined in constants.dart, so callers don't need to know the details.

  // District list (cached 24 hours)
  Future<void> cacheDistrictList(List<Map<String, dynamic>> data) =>
      set(CacheKeys.districtList, data);

  List<Map<String, dynamic>>? getCachedDistrictList() {
    return null; // cache disabled — always fetch live
  }

  // Risk map (cached 1 hour — changes frequently)
  Future<void> cacheRiskMap(Map<String, dynamic> data) =>
      set(CacheKeys.riskMap, data);

  Map<String, dynamic>? getCachedRiskMap() {
    return null; // cache disabled — always fetch live
  }

  // AI advice per district/crop (cached 6 hours)
  Future<void> cacheAIAdvice(
    String district,
    String crop,
    Map<String, dynamic> data,
  ) => set(CacheKeys.aiAdvice(district, crop), data);

  Map<String, dynamic>? getCachedAIAdvice(String district, String crop) {
    final data = get(
      CacheKeys.aiAdvice(district, crop),
      CacheDurations.aiAdvice,
    );
    return data as Map<String, dynamic>?;
  }

  // Yield data per district/crop (cached 12 hours)
  Future<void> cacheYieldData(
    String district,
    String crop,
    Map<String, dynamic> data,
  ) => set(CacheKeys.yield_(district, crop), data);

  Map<String, dynamic>? getCachedYieldData(String district, String crop) {
    return null; // cache disabled — always fetch live
  }

  // Stats per district (cached 12 hours)
  Future<void> cacheStats(String district, Map<String, dynamic> data) =>
      set(CacheKeys.stats(district), data);

  Map<String, dynamic>? getCachedStats(String district) {
    final data = get(CacheKeys.stats(district), CacheDurations.yieldData);
    return data as Map<String, dynamic>?;
  }

  // Weather per district (cached 30 minutes)
  Future<void> cacheWeather(String district, Map<String, dynamic> data) =>
      set(CacheKeys.weather(district), data);

  Map<String, dynamic>? getCachedWeather(String district) {
    final data = get(CacheKeys.weather(district), CacheDurations.weather);
    return data as Map<String, dynamic>?;
  }

  // Comparison (cached 6 hours)
  Future<void> cacheComparison(
      String d1, String d2, String crop, Map<String, dynamic> data) =>
      set(CacheKeys.comparison(d1, d2, crop), data);

  Map<String, dynamic>? getCachedComparison(String d1, String d2, String crop) {
    final data = get(
        CacheKeys.comparison(d1, d2, crop), CacheDurations.comparison);
    return data as Map<String, dynamic>?;
  }
}