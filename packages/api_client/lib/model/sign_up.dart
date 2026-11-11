//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SignUp {
  /// Returns a new [SignUp] instance.
  SignUp({
    required this.name,
  });

  /// The person's full name.
  String name;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SignUp &&
    other.name == name;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode);

  @override
  String toString() => 'SignUp[name=$name]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
    return json;
  }

  /// Returns a new [SignUp] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SignUp? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SignUp[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SignUp[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SignUp(
        name: mapValueOfType<String>(json, r'name')!,
      );
    }
    return null;
  }

  static List<SignUp> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SignUp>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SignUp.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SignUp> mapFromJson(dynamic json) {
    final map = <String, SignUp>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SignUp.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SignUp-objects as value to a dart map
  static Map<String, List<SignUp>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SignUp>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SignUp.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
  };
}

