import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/core/security/teacher_pin_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('stores a verifier instead of the plaintext PIN', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = TeacherPinService(preferences);

    await service.configure('246810');

    expect(service.isConfigured, isTrue);
    expect((await service.verify('246810')).isAccepted, isTrue);
    expect((await service.verify('111111')).isAccepted, isFalse);
    for (final key in preferences.getKeys()) {
      expect(preferences.get(key), isNot('246810'));
    }
  });

  test('rejects invalid setup values and locks repeated failures', () async {
    final service = TeacherPinService(await SharedPreferences.getInstance());
    expect(() => service.configure('12ab'), throwsFormatException);
    await service.configure('1234');

    PinCheckResult result = const PinCheckResult.rejected();
    for (var attempt = 0; attempt < 5; attempt++) {
      result = await service.verify('9999');
    }

    expect(result.isLocked, isTrue);
    expect((await service.verify('1234')).isLocked, isTrue);
  });
}
