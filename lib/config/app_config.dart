class AppConfig {
  static const String _apiBaseUrl = String.fromEnvironment(
    'CROPSENSE_API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static String get apiBaseUrl {
    final value = _apiBaseUrl.trim();
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
