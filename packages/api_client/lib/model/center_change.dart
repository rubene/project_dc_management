//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CenterChange {
  /// Returns a new [CenterChange] instance.
  CenterChange({
    required this.changeId,
    required this.expectedVersion,
    required this.timezone,
    this.reason,
  });

  /// A ULID created by the app, so a retried request can't create the record twice. Its time must be within 7 days of the server's clock. 
  String changeId;

  /// The profile's version the change was made against.
  ///
  /// Minimum value: 1
  int expectedVersion;

  /// The Center's new IANA timezone, such as America/Toronto.
  String timezone;

  /// Why the change was made, kept in the history.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CenterChange &&
    other.changeId == changeId &&
    other.expectedVersion == expectedVersion &&
    other.timezone == timezone &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (changeId.hashCode) +
    (expectedVersion.hashCode) +
    (timezone.hashCode) +
    (reason == null ? 0 : reason!.hashCode);

  @override
  String toString() => 'CenterChange[changeId=$changeId, expectedVersion=$expectedVersion, timezone=$timezone, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'changeId'] = this.changeId;
      json[r'expectedVersion'] = this.expectedVersion;
      json[r'timezone'] = this.timezone;
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
    return json;
  }

  /// Returns a new [CenterChange] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CenterChange? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CenterChange[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CenterChange[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CenterChange(
        changeId: mapValueOfType<String>(json, r'changeId')!,
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        reason: mapValueOfType<String>(json, r'reason'),
      );
    }
    return null;
  }

  static List<CenterChange> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CenterChange>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CenterChange.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CenterChange> mapFromJson(dynamic json) {
    final map = <String, CenterChange>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CenterChange.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CenterChange-objects as value to a dart map
  static Map<String, List<CenterChange>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CenterChange>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CenterChange.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'changeId',
    'expectedVersion',
    'timezone',
  };
}

