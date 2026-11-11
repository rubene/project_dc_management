//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Organization {
  /// Returns a new [Organization] instance.
  Organization({
    required this.id,
    required this.name,
    this.centers = const [],
  });

  String id;

  String name;

  List<CenterProfile> centers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Organization &&
    other.id == id &&
    other.name == name &&
    _deepEquality.equals(other.centers, centers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (centers.hashCode);

  @override
  String toString() => 'Organization[id=$id, name=$name, centers=$centers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'centers'] = this.centers;
    return json;
  }

  /// Returns a new [Organization] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Organization? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Organization[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Organization[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Organization(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        centers: CenterProfile.listFromJson(json[r'centers']),
      );
    }
    return null;
  }

  static List<Organization> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Organization>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Organization.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Organization> mapFromJson(dynamic json) {
    final map = <String, Organization>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Organization.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Organization-objects as value to a dart map
  static Map<String, List<Organization>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Organization>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Organization.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'centers',
  };
}

