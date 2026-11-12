import 'dart:js_interop';

// Only main.dart imports this, because it needs a browser.

@JS('Intl.DateTimeFormat')
extension type _DateTimeFormat._(JSObject _) implements JSObject {
  external _DateTimeFormat();

  external _ResolvedOptions resolvedOptions();
}

extension type _ResolvedOptions._(JSObject _) implements JSObject {
  external String get timeZone;
}

/// The browser's IANA timezone, such as America/Vancouver.
String browserTimezone() => _DateTimeFormat().resolvedOptions().timeZone;
