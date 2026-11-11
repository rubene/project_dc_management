//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CenterProfile {
  /// Returns a new [CenterProfile] instance.
  CenterProfile({
    required this.id,
    required this.orgId,
    required this.name,
    required this.currency,
    required this.timezone,
    required this.version,
  });

  String id;

  String orgId;

  String name;

  Currency currency;

  /// The Center's IANA timezone, such as America/Vancouver.
  String timezone;

  /// The profile's version, which a change must name.
  ///
  /// Minimum value: 1
  int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CenterProfile &&
    other.id == id &&
    other.orgId == orgId &&
    other.name == name &&
    other.currency == currency &&
    other.timezone == timezone &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (orgId.hashCode) +
    (name.hashCode) +
    (currency.hashCode) +
    (timezone.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'CenterProfile[id=$id, orgId=$orgId, name=$name, currency=$currency, timezone=$timezone, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'orgId'] = this.orgId;
      json[r'name'] = this.name;
      json[r'currency'] = this.currency;
      json[r'timezone'] = this.timezone;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [CenterProfile] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CenterProfile? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CenterProfile[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CenterProfile[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CenterProfile(
        id: mapValueOfType<String>(json, r'id')!,
        orgId: mapValueOfType<String>(json, r'orgId')!,
        name: mapValueOfType<String>(json, r'name')!,
        currency: Currency.fromJson(json[r'currency'])!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<CenterProfile> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CenterProfile>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CenterProfile.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CenterProfile> mapFromJson(dynamic json) {
    final map = <String, CenterProfile>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CenterProfile.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CenterProfile-objects as value to a dart map
  static Map<String, List<CenterProfile>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CenterProfile>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CenterProfile.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'orgId',
    'name',
    'currency',
    'timezone',
    'version',
  };
}

