import 'package:cropsense/app.dart';
import 'package:cropsense/data/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String? token;
  final Map<String, dynamic>? user;
  final bool loading;
  final String? error;

  const AuthState({
    this.token,
    this.user,
    this.loading = false,
    this.error,
  });

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({
    String? token,
    Map<String, dynamic>? user,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthState(
      token: clearSession ? null : token ?? this.token,
      user: clearSession ? null : user ?? this.user,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  // Show a client-side validation message without hitting the API.
  void setError(String message) =>
      state = state.copyWith(loading: false, error: message);

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _ref.read(apiServiceProvider).login(
            identifier: identifier,
            password: password,
          );
      state = AuthState(
        token: result['accessToken'] as String?,
        user: Map<String, dynamic>.from(result['user'] as Map),
      );
    } catch (error) {
      final msg = error is AppException ? error.message : error.toString();
      state = state.copyWith(loading: false, error: msg);
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _ref.read(apiServiceProvider).register(
            email: email,
            username: username,
            password: password,
          );
      state = AuthState(
        token: result['accessToken'] as String?,
        user: Map<String, dynamic>.from(result['user'] as Map),
      );
    } catch (error) {
      final msg = error is AppException ? error.message : error.toString();
      state = state.copyWith(loading: false, error: msg);
    }
  }

  void logout() => state = const AuthState();
}
