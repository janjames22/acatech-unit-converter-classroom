import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCheckResult {
  const PinCheckResult._({
    required this.isAccepted,
    this.lockedFor = Duration.zero,
  });

  const PinCheckResult.accepted() : this._(isAccepted: true);

  const PinCheckResult.rejected() : this._(isAccepted: false);

  const PinCheckResult.locked(Duration duration)
    : this._(isAccepted: false, lockedFor: duration);

  final bool isAccepted;
  final Duration lockedFor;

  bool get isLocked => lockedFor > Duration.zero;
}

class TeacherPinService {
  TeacherPinService(this._preferences);

  static const _verifierKey = 'teacher_pin.verifier';
  static const _saltKey = 'teacher_pin.salt';
  static const _iterationsKey = 'teacher_pin.iterations';
  static const _failuresKey = 'teacher_pin.failures';
  static const _lockedUntilKey = 'teacher_pin.locked_until';
  static const _defaultIterations = 20000;

  final SharedPreferences _preferences;

  bool get isConfigured =>
      _preferences.getString(_verifierKey)?.isNotEmpty ?? false;

  Future<void> configure(String pin) async {
    _validatePin(pin);
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final verifier = _derive(pin, salt, _defaultIterations);
    await _preferences.setString(_saltKey, base64UrlEncode(salt));
    await _preferences.setString(_verifierKey, base64UrlEncode(verifier));
    await _preferences.setInt(_iterationsKey, _defaultIterations);
    await _clearFailures();
  }

  Future<PinCheckResult> verify(String pin) async {
    final now = DateTime.now().toUtc();
    final lockedUntilValue = _preferences.getString(_lockedUntilKey);
    final lockedUntil = lockedUntilValue == null
        ? null
        : DateTime.tryParse(lockedUntilValue);
    if (lockedUntil != null && lockedUntil.isAfter(now)) {
      return PinCheckResult.locked(lockedUntil.difference(now));
    }

    final saltValue = _preferences.getString(_saltKey);
    final expectedValue = _preferences.getString(_verifierKey);
    if (saltValue == null || expectedValue == null) {
      return const PinCheckResult.rejected();
    }

    final salt = base64Url.decode(saltValue);
    final expected = base64Url.decode(expectedValue);
    final iterations =
        _preferences.getInt(_iterationsKey) ?? _defaultIterations;
    final actual = _derive(pin, salt, iterations);

    if (_constantTimeEquals(actual, expected)) {
      await _clearFailures();
      return const PinCheckResult.accepted();
    }

    final failures = (_preferences.getInt(_failuresKey) ?? 0) + 1;
    await _preferences.setInt(_failuresKey, failures);
    if (failures >= 5) {
      final exponent = min(failures - 5, 5);
      final lockSeconds = 30 * (1 << exponent);
      final until = now.add(Duration(seconds: lockSeconds));
      await _preferences.setString(_lockedUntilKey, until.toIso8601String());
      return PinCheckResult.locked(Duration(seconds: lockSeconds));
    }
    return const PinCheckResult.rejected();
  }

  Future<void> remove() async {
    await _preferences.remove(_saltKey);
    await _preferences.remove(_verifierKey);
    await _preferences.remove(_iterationsKey);
    await _clearFailures();
  }

  Future<void> _clearFailures() async {
    await _preferences.remove(_failuresKey);
    await _preferences.remove(_lockedUntilKey);
  }

  static void _validatePin(String pin) {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      throw const FormatException('PIN must contain 4 to 6 digits.');
    }
  }

  static List<int> _derive(String pin, List<int> salt, int iterations) {
    final key = utf8.encode(pin);
    final hmac = Hmac(sha256, key);
    final block = [...salt, 0, 0, 0, 1];
    var value = hmac.convert(block).bytes;
    final result = List<int>.from(value);
    for (var index = 1; index < iterations; index++) {
      value = hmac.convert(value).bytes;
      for (var byteIndex = 0; byteIndex < result.length; byteIndex++) {
        result[byteIndex] ^= value[byteIndex];
      }
    }
    return result;
  }

  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}
