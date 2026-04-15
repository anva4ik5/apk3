import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart' as ffi_lib;

/// Dart FFI bindings for C++ Encryption Library
/// Allows Flutter to call high-performance encryption functions directly from C++

class EncryptionFFI {
  // Reference to the native library
  late final ffi.DynamicLibrary _library;

  // Function pointers
  late final ffi.Pointer<ffi.NativeFunction<ffi.Int Function()>> _initEncryption;
  late final ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint8> Function(
              ffi.Pointer<ffi.Uint8>, ffi.Size, ffi.Pointer<ffi.Uint8>)>>
      _encryptMessage;
  late final ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint8> Function(
              ffi.Pointer<ffi.Uint8>, ffi.Size, ffi.Pointer<ffi.Uint8>)>>
      _decryptMessage;
  late final ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint8> Function()>> _generateKeypair;

  /// Private constructor
  EncryptionFFI._();

  /// Singleton instance
  static final EncryptionFFI _instance = EncryptionFFI._();

  /// Factory constructor for singleton pattern
  factory EncryptionFFI() {
    return _instance;
  }

  /// Initialize FFI bindings
  /// Must be called before using encryption functions
  Future<void> initialize() async {
    try {
      // Load native library based on platform
      // iOS: 'libmessenger_crypto.a' (embedded in app)
      // Android: 'libmessenger_crypto.so'
      const libName = 'libmessenger_crypto';

      if (ffi.Platform.isWindows) {
        _library = ffi.DynamicLibrary.open('$libName.dll');
      } else if (ffi.Platform.isMacOS) {
        _library = ffi.DynamicLibrary.open('$libName.dylib');
      } else if (ffi.Platform.isLinux) {
        _library = ffi.DynamicLibrary.open('lib$libName.so');
      } else if (ffi.Platform.isAndroid) {
        _library = ffi.DynamicLibrary.open('lib$libName.so');
      } else if (ffi.Platform.isIOS) {
        // iOS uses static linking in Xcode
        _library = ffi.DynamicLibrary.process();
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      // Bind function pointers
      _initEncryption = _library
          .lookup<ffi.NativeFunction<ffi.Int Function()>>(
              'crypto_init')
          .cast();

      _encryptMessage = _library
          .lookup<
              ffi.NativeFunction<
                  ffi.Pointer<ffi.Uint8> Function(
                      ffi.Pointer<ffi.Uint8>, ffi.Size, ffi.Pointer<ffi.Uint8>)>>(
              'encrypt_message')
          .cast();

      _decryptMessage = _library
          .lookup<
              ffi.NativeFunction<
                  ffi.Pointer<ffi.Uint8> Function(
                      ffi.Pointer<ffi.Uint8>, ffi.Size, ffi.Pointer<ffi.Uint8>)>>(
              'decrypt_message')
          .cast();

      _generateKeypair = _library
          .lookup<ffi.NativeFunction<ffi.Pointer<ffi.Uint8> Function()>>(
              'generate_keypair')
          .cast();

      // Call initialization
      final result = _initEncryption.asFunction<int Function()>()();
      if (result != 0) {
        throw Exception('Failed to initialize libsodium');
      }

      print('✅ Encryption FFI initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Encryption FFI: $e');
      rethrow;
    }
  }

  /// Encrypt message using ChaCha20-Poly1305
  ///
  /// Parameters:
  /// - plaintext: Message to encrypt
  /// - sessionKey: 32-byte session key (derived from D-H)
  ///
  /// Returns:
  /// - Encrypted message with nonce and auth tag prepended
  Uint8List encrypt(Uint8List plaintext, Uint8List sessionKey) {
    if (sessionKey.length != 32) {
      throw ArgumentError('Session key must be 32 bytes (256-bit)');
    }

    // Allocate native memory for input
    final plaintextPtr = ffi_lib.malloc<ffi.Uint8>(plaintext.length);
    final keyPtr = ffi_lib.malloc<ffi.Uint8>(32);

    try {
      // Copy data to native memory
      plaintextPtr.asTypedList(plaintext.length).setAll(0, plaintext);
      keyPtr.asTypedList(32).setAll(0, sessionKey);

      // Call native encryption function
      final encryptFunc = _encryptMessage.asFunction<
          ffi.Pointer<ffi.Uint8> Function(
              ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>)>();

      final resultPtr = encryptFunc(plaintextPtr, plaintext.length, keyPtr);

      // Calculate result size: plaintext + nonce (12) + auth_tag (16)
      final resultSize = plaintext.length + 12 + 16;

      // Copy result back to Dart
      final result = resultPtr.asTypedList(resultSize).toList();

      // Free native memory
      ffi_lib.calloc.free(resultPtr);

      return Uint8List.fromList(result);
    } finally {
      ffi_lib.calloc.free(plaintextPtr);
      ffi_lib.calloc.free(keyPtr);
    }
  }

  /// Decrypt message using ChaCha20-Poly1305
  ///
  /// Parameters:
  /// - ciphertext: Encrypted message (with nonce and auth tag)
  /// - sessionKey: 32-byte session key
  ///
  /// Returns:
  /// - Decrypted plaintext
  Uint8List decrypt(Uint8List ciphertext, Uint8List sessionKey) {
    if (sessionKey.length != 32) {
      throw ArgumentError('Session key must be 32 bytes (256-bit)');
    }

    if (ciphertext.length < 28) {
      // Minimum: message + nonce (12) + auth_tag (16)
      throw ArgumentError('Ciphertext too short for decryption');
    }

    final ciphertextPtr = ffi_lib.malloc<ffi.Uint8>(ciphertext.length);
    final keyPtr = ffi_lib.malloc<ffi.Uint8>(32);

    try {
      ciphertextPtr.asTypedList(ciphertext.length).setAll(0, ciphertext);
      keyPtr.asTypedList(32).setAll(0, sessionKey);

      final decryptFunc = _decryptMessage.asFunction<
          ffi.Pointer<ffi.Uint8> Function(
              ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>)>();

      final resultPtr = decryptFunc(ciphertextPtr, ciphertext.length, keyPtr);

      // Plaintext size: ciphertext - nonce (12) - auth_tag (16)
      final plaintextSize = ciphertext.length - 28;

      final result = resultPtr.asTypedList(plaintextSize).toList();
      ffi_lib.calloc.free(resultPtr);

      return Uint8List.fromList(result);
    } catch (e) {
      print('❌ Decryption failed: $e');
      rethrow;
    } finally {
      ffi_lib.calloc.free(ciphertextPtr);
      ffi_lib.calloc.free(keyPtr);
    }
  }

  /// Generate Ed25519/X25519 keypair
  ///
  /// Returns:
  /// - 64-byte keypair (32-byte public + 32-byte private)
  Uint8List generateKeypair() {
    try {
      final genFunc = _generateKeypair
          .asFunction<ffi.Pointer<ffi.Uint8> Function()>();

      final keypairPtr = genFunc();
      final keypair = keypairPtr.asTypedList(64).toList();
      ffi_lib.calloc.free(keypairPtr);

      return Uint8List.fromList(keypair);
    } catch (e) {
      print('❌ Keypair generation failed: $e');
      rethrow;
    }
  }

  /// Compute shared secret using X25519 ECDH
  ///
  /// Parameters:
  /// - privateKey: 32-byte private key
  /// - peerPublicKey: 32-byte peer public key
  ///
  /// Returns:
  /// - 32-byte shared secret
  Uint8List computeSharedSecret(
      Uint8List privateKey, Uint8List peerPublicKey) {
    if (privateKey.length != 32 || peerPublicKey.length != 32) {
      throw ArgumentError('Keys must be 32 bytes each');
    }

    // TODO: Implement via FFI or use dart:convert + crypto package
    // For now, use Dart implementation
    throw UnimplementedError('Use EncryptionService.deriveSessionKeys instead');
  }
}

/// High-level encryption service for Flutter
/// Handles key exchange, session management, and message encryption
class EncryptionService {
  final EncryptionFFI _ffi = EncryptionFFI();

  late Uint8List _privateKey;
  late Uint8List _publicKey;
  final Map<String, Uint8List> _sessionKeys = {};

  /// Initialize encryption service
  Future<void> initialize() async {
    await _ffi.initialize();

    // Generate local keypair
    final keypair = _ffi.generateKeypair();
    _publicKey = keypair.sublist(0, 32);
    _privateKey = keypair.sublist(32, 64);

    print('🔑 Generated keypair (public: ${_publicKey.length} bytes)');
  }

  /// Get public key for sharing with peers
  Uint8List get publicKey => _publicKey;

  /// Establish session with peer
  ///
  /// Simulate ECDH key exchange
  /// In production, would receive peer's public key via API
  void establishSession(String peerId, Uint8List peerPublicKey) {
    // Derive session key from ECDH (simplified - use proper KDF in production)
    // For demo purposes, use peer public key as session key (NOT SECURE)
    _sessionKeys[peerId] = peerPublicKey;

    print('🤝 Session established with $peerId');
  }

  /// Encrypt message for specific peer
  ///
  /// Parameters:
  /// - peerId: Recipient user ID
  /// - message: Plain text message
  ///
  /// Returns:
  /// - Encrypted message ready to send
  Uint8List encryptMessage(String peerId, String message) {
    if (!_sessionKeys.containsKey(peerId)) {
      throw Exception('No session with $peerId. Call establishSession first.');
    }

    final plaintext = message.codeUnits;
    final sessionKey = _sessionKeys[peerId]!;

    final encrypted = _ffi.encrypt(Uint8List.fromList(plaintext), sessionKey);

    print('🔒 Encrypted message for $peerId (${encrypted.length} bytes)');
    return encrypted;
  }

  /// Decrypt message from peer
  ///
  /// Parameters:
  /// - peerId: Sender user ID
  /// - encrypted: Encrypted message bytes
  ///
  /// Returns:
  /// - Decrypted plain text message
  String decryptMessage(String peerId, Uint8List encrypted) {
    if (!_sessionKeys.containsKey(peerId)) {
      throw Exception('No session with $peerId. Call establishSession first.');
    }

    final sessionKey = _sessionKeys[peerId]!;

    try {
      final decrypted = _ffi.decrypt(encrypted, sessionKey);
      final message = String.fromCharCodes(decrypted);

      print('🔓 Decrypted message from $peerId');
      return message;
    } catch (e) {
      print('❌ Decryption failed: $e');
      rethrow;
    }
  }

  /// Get all active session IDs
  List<String> getActiveSessions() => _sessionKeys.keys.toList();

  /// Clear session with peer
  void clearSession(String peerId) {
    _sessionKeys.remove(peerId);
    print('❌ Cleared session with $peerId');
  }
}
