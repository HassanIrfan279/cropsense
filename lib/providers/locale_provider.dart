// lib/providers/locale_provider.dart
//
// Controls the app language — English or Urdu.
// Toggle with: ref.read(localeProvider.notifier).state = const Locale('ur')

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Starts in English. Persisted across sessions via Hive in a future phase.
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
});

// Helper: is the current locale Urdu?
// Usage: final isUrdu = ref.watch(isUrduProvider);
final isUrduProvider = Provider<bool>((ref) {
  return ref.watch(localeProvider).languageCode == 'ur';
});