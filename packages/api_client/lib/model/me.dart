//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Me {
  /// Returns a new [Me] instance.
  Me({
    required this.personId,
    required this.name,
    required this.email,
    this.organizations = const [],
    this.centers = const [],
  });

  String personId;

  String name;

  String email;

  List<OrganizationAccess> organizations;

  List<CenterAccess> centers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Me &&
    other.personId == personId &&
    other.name == name &&
    other.email == email &&
    _deepEquality.equals(other.organizations, organizations) &&
    _deepEquality.equals(other.centers, centers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (personId.hashCode) +
    (name.hashCode) +
    (email.hashCode) +
    (organizations.hashCode) +
    (centers.hashCode);

  @override
  String toString() => 'Me[personId=$personId, name=$name, email=$email, organizations=$organizations, centers=$centers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'personId'] = this.personId;
      json[r'name'] = this.name;
      json[r'email'] = this.email;
      json[r'organizations'] = this.organizations;
      json[r'centers'] = this.centers;
    return json;
  }

  /// Returns a new [Me] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Me? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Me[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Me[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Me(
        personId: mapValueOfType<String>(json, r'personId')!,
        name: mapValueOfType<String>(json, r'name')!,
        email: mapValueOfType<String>(json, r'email')!,
        organizations: OrganizationAccess.listFromJson(json[r'organizations']),
        centers: CenterAccess.listFromJson(json[r'centers']),
      );
    }
    return null;
  }

  static List<Me> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Me>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Me.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Me> mapFromJson(dynamic json) {
    final map = <String, Me>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Me.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Me-objects as value to a dart map
  static Map<String, List<Me>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Me>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Me.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'personId',
    'name',
    'email',
    'organizations',
    'centers',
  };
}

