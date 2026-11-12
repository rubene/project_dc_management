import 'dart:math';

// Crockford's base 32, as ULIDs use it.
const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
final _random = Random.secure();

/// A new ULID for a record made in the app (docs/data-model.md, "IDs created
/// on the device"): 10 characters of time in milliseconds, then 16 random.
///
/// Written here rather than taken from a package: the time is encoded with
/// division, which is exact in the browser for any date, where bit shifts work
/// on 32 bits and once put IDs in 1970.
String newDeviceId({DateTime? now}) {
  var time = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final timePart = List.filled(10, '');
  for (var i = 9; i >= 0; i--) {
    timePart[i] = _alphabet[time % 32];
    time ~/= 32;
  }
  final randomPart = [for (var i = 0; i < 16; i++) _alphabet[_random.nextInt(32)]];
  return [...timePart, ...randomPart].join();
}
