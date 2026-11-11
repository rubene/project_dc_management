//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NewOrganization {
  /// Returns a new [NewOrganization] instance.
  NewOrganization({
    required this.id,
    required this.name,
    required this.center,
  });

  /// A ULID created by the app, so a retried request can't create the record twice. Its time must be within 7 days of the server's clock. 
  String id;

  String name;

  NewCenter center;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NewOrganization &&
    other.id == id &&
    other.name == name &&
    other.center == center;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (center.hashCode);

  @override
  String toString() => 'NewOrganization[id=$id, name=$name, center=$center]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'center'] = this.center;
    return json;
  }

  /// Returns a new [NewOrganization] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NewOrganization? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "NewOrganization[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "NewOrganization[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return NewOrganization(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        center: NewCenter.fromJson(json[r'center'])!,
      );
    }
    return null;
  }

  static List<NewOrganization> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NewOrganization>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NewOrganization.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NewOrganization> mapFromJson(dynamic json) {
    final map = <String, NewOrganization>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NewOrganization.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NewOrganization-objects as value to a dart map
  static Map<String, List<NewOrganization>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NewOrganization>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NewOrganization.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'center',
  };
}

