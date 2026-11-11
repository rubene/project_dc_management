//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CenterVersion {
  /// Returns a new [CenterVersion] instance.
  CenterVersion({
    required this.version,
    required this.name,
    required this.currency,
    required this.timezone,
    required this.recordedAt,
    required this.recordedBy,
    this.reason,
  });

  /// Minimum value: 1
  int version;

  String name;

  Currency currency;

  String timezone;

  /// When the server saved this version.
  DateTime recordedAt;

  /// The person ID of whoever saved this version.
  String recordedBy;

  /// Why this version was saved. The first is \"Created\".
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CenterVersion &&
    other.version == version &&
    other.name == name &&
    other.currency == currency &&
    other.timezone == timezone &&
    other.recordedAt == recordedAt &&
    other.recordedBy == recordedBy &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (version.hashCode) +
    (name.hashCode) +
    (currency.hashCode) +
    (timezone.hashCode) +
    (recordedAt.hashCode) +
    (recordedBy.hashCode) +
    (reason == null ? 0 : reason!.hashCode);

  @override
  String toString() => 'CenterVersion[version=$version, name=$name, currency=$currency, timezone=$timezone, recordedAt=$recordedAt, recordedBy=$recordedBy, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'version'] = this.version;
      json[r'name'] = this.name;
      json[r'currency'] = this.currency;
      json[r'timezone'] = this.timezone;
      json[r'recordedAt'] = this.recordedAt.toUtc().toIso8601String();
      json[r'recordedBy'] = this.recordedBy;
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
    return json;
  }

  /// Returns a new [CenterVersion] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CenterVersion? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CenterVersion[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CenterVersion[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CenterVersion(
        version: mapValueOfType<int>(json, r'version')!,
        name: mapValueOfType<String>(json, r'name')!,
        currency: Currency.fromJson(json[r'currency'])!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        recordedAt: mapDateTime(json, r'recordedAt', r'')!,
        recordedBy: mapValueOfType<String>(json, r'recordedBy')!,
        reason: mapValueOfType<String>(json, r'reason'),
      );
    }
    return null;
  }

  static List<CenterVersion> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CenterVersion>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CenterVersion.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CenterVersion> mapFromJson(dynamic json) {
    final map = <String, CenterVersion>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CenterVersion.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CenterVersion-objects as value to a dart map
  static Map<String, List<CenterVersion>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CenterVersion>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CenterVersion.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'version',
    'name',
    'currency',
    'timezone',
    'recordedAt',
    'recordedBy',
  };
}

