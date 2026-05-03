import 'package:cropsense/app.dart';
import 'package:cropsense/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FieldManagementState {
  final List<Map<String, dynamic>> fields;
  final List<Map<String, dynamic>> comparison;
  final Map<String, dynamic>? selectedField;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? advice;
  final bool loading;
  final String? error;

  const FieldManagementState({
    this.fields = const [],
    this.comparison = const [],
    this.selectedField,
    this.analytics,
    this.advice,
    this.loading = false,
    this.error,
  });

  FieldManagementState copyWith({
    List<Map<String, dynamic>>? fields,
    List<Map<String, dynamic>>? comparison,
    Map<String, dynamic>? selectedField,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? advice,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return FieldManagementState(
      fields: fields ?? this.fields,
      comparison: comparison ?? this.comparison,
      selectedField: clearSelection ? null : selectedField ?? this.selectedField,
      analytics: clearSelection ? null : analytics ?? this.analytics,
      advice: clearSelection ? null : advice ?? this.advice,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final fieldManagementProvider =
    StateNotifierProvider<FieldManagementNotifier, FieldManagementState>(
  (ref) => FieldManagementNotifier(ref),
);

class FieldManagementNotifier extends StateNotifier<FieldManagementState> {
  final Ref _ref;

  FieldManagementNotifier(this._ref) : super(const FieldManagementState());

  String get _token {
    final token = _ref.read(authProvider).token;
    if (token == null) throw Exception('Please log in first.');
    return token;
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final data = await _ref.read(apiServiceProvider).listFields(token: _token);
      final fields = _rows(data['fields']);
      final comparison = _rows(data['comparison']);
      state = state.copyWith(
        fields: fields,
        comparison: comparison,
        loading: false,
        clearSelection: fields.isEmpty,
      );
      if (fields.isNotEmpty && state.selectedField == null) {
        await selectField(fields.first['id'] as String);
      }
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> selectField(String fieldId) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final detail = await _ref
          .read(apiServiceProvider)
          .getFieldDetail(token: _token, fieldId: fieldId);
      final selected = Map<String, dynamic>.from(detail['field'] as Map);
      final analytics = Map<String, dynamic>.from(detail['analytics'] as Map);
      state = state.copyWith(
        selectedField: selected,
        analytics: analytics,
        loading: false,
      );
      await loadAdvice();
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> createField(Map<String, dynamic> request) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _ref
          .read(apiServiceProvider)
          .createField(token: _token, request: request);
      await load();
      await selectField((result['field'] as Map)['id'] as String);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> updateField(String fieldId, Map<String, dynamic> request) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _ref
          .read(apiServiceProvider)
          .updateField(token: _token, fieldId: fieldId, request: request);
      await load();
      await selectField(fieldId);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> deleteField(String fieldId) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _ref
          .read(apiServiceProvider)
          .deleteField(token: _token, fieldId: fieldId);
      state = state.copyWith(clearSelection: true);
      await load();
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> addLog({
    required String fieldId,
    required String type,
    required Map<String, dynamic> request,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _ref.read(apiServiceProvider).addFieldLog(
            token: _token,
            fieldId: fieldId,
            type: type,
            request: request,
          );
      await refreshAnalytics(fieldId);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> refreshAnalytics(String fieldId) async {
    final data = await _ref
        .read(apiServiceProvider)
        .getFieldAnalytics(token: _token, fieldId: fieldId);
    state = state.copyWith(
      analytics: Map<String, dynamic>.from(data['analytics'] as Map),
      comparison: _rows(data['comparison']),
      loading: false,
    );
    await loadAdvice();
  }

  Future<void> loadAdvice() async {
    final fieldId = state.selectedField?['id'] as String?;
    if (fieldId == null) return;
    try {
      final data = await _ref
          .read(apiServiceProvider)
          .getFieldAiAdvice(token: _token, fieldId: fieldId);
      state = state.copyWith(
        advice: Map<String, dynamic>.from(data['advice'] as Map),
      );
    } catch (_) {
      // Keep field management usable even if Grok/API advice is unavailable.
    }
  }

  Future<Map<String, dynamic>> buildReport(String fieldId) async {
    final data = await _ref
        .read(apiServiceProvider)
        .getFieldReport(token: _token, fieldId: fieldId);
    return Map<String, dynamic>.from(data['report'] as Map);
  }

  void reset() => state = const FieldManagementState();
}

List<Map<String, dynamic>> _rows(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  return const [];
}
