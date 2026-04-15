class AppConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://apk2-production.up.railway.app',
  );

  static String get wsUrl {
    final base = apiUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$base/ws';
  }
}
