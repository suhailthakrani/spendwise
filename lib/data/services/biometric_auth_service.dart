import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthException implements Exception {
  BiometricAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } on PlatformException {
      return false;
    }
  }

  Future<String> label() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) {
        return 'Face ID';
      }
      if (types.contains(BiometricType.fingerprint) ||
          types.contains(BiometricType.strong) ||
          types.contains(BiometricType.weak)) {
        return 'Fingerprint';
      }
    } on PlatformException {
      // Fall through to generic copy.
    }
    return 'Biometrics';
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (error) {
      throw BiometricAuthException(
        error.message ?? 'Biometric sign-in is not available',
      );
    }
  }
}
