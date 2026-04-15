/// Application configuration constants
class AppConfig {
  // API Configuration
  static const String baseUrl = 'https://api.apk2.railway.app';
  static const String wsUrl = 'wss://ws.apk2.railway.app';
  
  // Local development (override for your setup)
  // static const String baseUrl = 'http://localhost:8080';
  // static const String wsUrl = 'ws://localhost:8080';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API Endpoints
  static const String authEndpoint = '/api/v1/auth';
  static const String messagesEndpoint = '/api/v1/messages';
  static const String usersEndpoint = '/api/v1/users';
  static const String channelsEndpoint = '/api/v1/channels';
  
  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCrashReporting = true;
  
  // Encryption
  static const String encryptionAlgorithm = 'ChaCha20-Poly1305';
  static const String keyExchange = 'X25519';
}
