import 'package:dc_admin_web/device_id.dart';
import 'package:flutter_test/flutter_test.dart';

// The API refuses an ID whose time is more than 7 days from its own clock, so
// the time inside the ID must be exact. Run this in Chrome too
// (`flutter test --platform chrome test/device_id_test.dart`): the browser's
// integers differ from the Dart VM's, which broke a ULID package before.
const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

int _timeOf(String ulid) =>
    ulid.substring(0, 10).split('').fold(0, (time, char) => time * 32 + _alphabet.indexOf(char));

void main() {
  test('a new ID is a ULID holding the time it was made', () {
    final madeAt = DateTime.utc(2026, 11, 12, 4, 15, 30, 123);

    final id = newDeviceId(now: madeAt);

    expect(id, matches(RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$')));
    expect(_timeOf(id), madeAt.millisecondsSinceEpoch);
  });

  test('IDs made at the same moment differ', () {
    final now = DateTime.utc(2026, 11, 12);

    expect({for (var i = 0; i < 100; i++) newDeviceId(now: now)}, hasLength(100));
  });
}
