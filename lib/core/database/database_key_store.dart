import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Holds the SQLCipher passphrase and an obscured on-disk path.
class DatabaseCredentials {
  const DatabaseCredentials({
    required this.hexKey,
    required this.filePath,
  });

  /// 32-byte key as lowercase hex (64 chars) for `PRAGMA key = "x'…'"`.
  final String hexKey;
  final String filePath;
}

/// Generates and persists DB secrets in platform secure storage
/// (Android Keystore / iOS Keychain). Never logs or hardcodes keys.
abstract final class DatabaseKeyStore {
  static const _keyAlias = 'sw.db.mk';
  static const _nameAlias = 'sw.db.fn';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<DatabaseCredentials> obtain() async {
    final hexKey = await _readOrCreateHexKey();
    final fileName = await _readOrCreateFileName();
    final directory = await getApplicationSupportDirectory();
    return DatabaseCredentials(
      hexKey: hexKey,
      filePath: p.join(directory.path, fileName),
    );
  }

  static Future<String> _readOrCreateHexKey() async {
    final existing = await _storage.read(key: _keyAlias);
    if (existing != null &&
        existing.length == 64 &&
        RegExp(r'^[0-9a-f]+$').hasMatch(existing)) {
      return existing;
    }

    final bytes = List<int>.generate(32, (_) => _secureRandom.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _keyAlias, value: hex);
    return hex;
  }

  static Future<String> _readOrCreateFileName() async {
    final existing = await _storage.read(key: _nameAlias);
    if (existing != null &&
        existing.isNotEmpty &&
        !existing.contains('/') &&
        !existing.contains('\\')) {
      return existing;
    }

    // Obscured name — not "spendwise.sqlite" / no finance keywords.
    final entropy = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    final name = '${base64UrlEncode(entropy).replaceAll('=', '')}.dat';
    await _storage.write(key: _nameAlias, value: name);
    return name;
  }

  static final Random _secureRandom = Random.secure();
}
