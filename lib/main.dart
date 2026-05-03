// lib/main.dart
//
// CropSense entry point.
// ─────────────────────────────────────────────────────────────────────────
// This file runs first. It must:
//   1. Initialize Hive (local cache)
//   2. Wrap everything in ProviderScope (enables Riverpod)
//   3. Launch the app

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/data/services/cache_service.dart';
import 'package:cropsense/app.dart';

// The cache service instance — created once, shared everywhere via a
// Riverpod provider defined in app.dart
final cacheService = CacheService();

Future<void> main() async {
  // Required before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive cache — must happen before any provider tries to read cache
  await cacheService.init();

  // Clear stale mock data from any previous session so providers always
  // fetch fresh data from the real backend on startup.
  await cacheService.clearAll();

  // ProviderScope is the Riverpod root — every provider lives inside it.
  // We pass cacheService as an override so providers can access it.
  runApp(
    const ProviderScope(
      child: CropSenseApp(),
    ),
  );
}
