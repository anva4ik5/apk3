// Этот файл не используется - используется lib/config.dart
// Оставлен для совместимости
class AppConfig {
  static const String baseUrl = 'https://apk2-production.up.railway.app';
  static const String wsUrl = 'wss://apk2-production.up.railway.app/ws';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authEndpoint = '/api/auth';
  static const String messagesEndpoint = '/api/chats';
  static const String usersEndpoint = '/api/auth/users';
  static const String channelsEndpoint = '/api/channels';

  static const bool enableLogging = true;
  static const bool enableCrashReporting = true;

  static const String encryptionAlgorithm = 'ChaCha20-Poly1305';
  static const String keyExchange = 'X25519';
}
