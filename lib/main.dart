// lib/main.dart
//
// CropSense entry point.
// ─────────────────────────────────────────────────────────────────────────
// This file runs first. It must:
//   1. Load environment variables from .env
//   2. Initialize Hive (local cache)
//   3. Wrap everything in ProviderScope (enables Riverpod)
//   4. Launch the app

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cropsense/data/services/cache_service.dart';
import 'package:cropsense/app.dart';

// The cache service instance — created once, shared everywhere via a
// Riverpod provider defined in app.dart
final cacheService = CacheService();

Future<void> main() async {
  // Required before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file — must happen before ApiService reads CROPSENSE_API_URL
  await dotenv.load(fileName: '.env');

  // Initialize Hive cache — must happen before any provider tries to read cache
  await cacheService.init();

  // ProviderScope is the Riverpod root — every provider lives inside it.
  // We pass cacheService as an override so providers can access it.
  runApp(
    ProviderScope(
      child: const CropSenseApp(),
    ),
  );
}