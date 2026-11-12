//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CenterAccess {
  /// Returns a new [CenterAccess] instance.
  CenterAccess({
    required this.id,
    required this.name,
    required this.orgId,
    this.roles = const [],
  });

  String id;

  String name;

  String orgId;

  List<CenterAccessRolesEnum> roles;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CenterAccess &&
    other.id == id &&
    other.name == name &&
    other.orgId == orgId &&
    _deepEquality.equals(other.roles, roles);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (orgId.hashCode) +
    (roles.hashCode);

  @override
  String toString() => 'CenterAccess[id=$id, name=$name, orgId=$orgId, roles=$roles]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'orgId'] = this.orgId;
      json[r'roles'] = this.roles;
    return json;
  }

  /// Returns a new [CenterAccess] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CenterAccess? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CenterAccess[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CenterAccess[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CenterAccess(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        orgId: mapValueOfType<String>(json, r'orgId')!,
        roles: CenterAccessRolesEnum.listFromJson(json[r'roles']),
      );
    }
    return null;
  }

  static List<CenterAccess> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CenterAccess>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CenterAccess.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CenterAccess> mapFromJson(dynamic json) {
    final map = <String, CenterAccess>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CenterAccess.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CenterAccess-objects as value to a dart map
  static Map<String, List<CenterAccess>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CenterAccess>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CenterAccess.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'orgId',
    'roles',
  };
}


class CenterAccessRolesEnum {
  /// Instantiate a new enum with the provided [value].
  const CenterAccessRolesEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const admin = CenterAccessRolesEnum._(r'Admin');

  /// List of all possible values in this [enum][CenterAccessRolesEnum].
  static const values = <CenterAccessRolesEnum>[
    admin,
  ];

  static CenterAccessRolesEnum? fromJson(dynamic value) => CenterAccessRolesEnumTypeTransformer().decode(value);

  static List<CenterAccessRolesEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CenterAccessRolesEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CenterAccessRolesEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CenterAccessRolesEnum] to String,
/// and [decode] dynamic data back to [CenterAccessRolesEnum].
class CenterAccessRolesEnumTypeTransformer {
  factory CenterAccessRolesEnumTypeTransformer() => _instance ??= const CenterAccessRolesEnumTypeTransformer._();

  const CenterAccessRolesEnumTypeTransformer._();

  String encode(CenterAccessRolesEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CenterAccessRolesEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CenterAccessRolesEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'Admin': return CenterAccessRolesEnum.admin;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CenterAccessRolesEnumTypeTransformer] instance.
  static CenterAccessRolesEnumTypeTransformer? _instance;
}


