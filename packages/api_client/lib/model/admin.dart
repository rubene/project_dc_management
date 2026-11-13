//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Admin {
  /// Returns a new [Admin] instance.
  Admin({
    required this.personId,
    required this.name,
    required this.email,
  });

  String personId;

  String name;

  String email;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Admin &&
    other.personId == personId &&
    other.name == name &&
    other.email == email;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (personId.hashCode) +
    (name.hashCode) +
    (email.hashCode);

  @override
  String toString() => 'Admin[personId=$personId, name=$name, email=$email]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'personId'] = this.personId;
      json[r'name'] = this.name;
      json[r'email'] = this.email;
    return json;
  }

  /// Returns a new [Admin] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Admin? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Admin[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Admin[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Admin(
        personId: mapValueOfType<String>(json, r'personId')!,
        name: mapValueOfType<String>(json, r'name')!,
        email: mapValueOfType<String>(json, r'email')!,
      );
    }
    return null;
  }

  static List<Admin> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Admin>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Admin.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Admin> mapFromJson(dynamic json) {
    final map = <String, Admin>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Admin.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Admin-objects as value to a dart map
  static Map<String, List<Admin>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Admin>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Admin.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'personId',
    'name',
    'email',
  };
}

