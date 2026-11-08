//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class HealthUnavailable {
  /// Returns a new [HealthUnavailable] instance.
  HealthUnavailable({
    required this.status,
    required this.database,
  });

  HealthUnavailableStatusEnum status;

  HealthUnavailableDatabaseEnum database;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HealthUnavailable &&
    other.status == status &&
    other.database == database;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode) +
    (database.hashCode);

  @override
  String toString() => 'HealthUnavailable[status=$status, database=$database]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
      json[r'database'] = this.database;
    return json;
  }

  /// Returns a new [HealthUnavailable] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static HealthUnavailable? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "HealthUnavailable[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "HealthUnavailable[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return HealthUnavailable(
        status: HealthUnavailableStatusEnum.fromJson(json[r'status'])!,
        database: HealthUnavailableDatabaseEnum.fromJson(json[r'database'])!,
      );
    }
    return null;
  }

  static List<HealthUnavailable> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HealthUnavailable>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HealthUnavailable.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, HealthUnavailable> mapFromJson(dynamic json) {
    final map = <String, HealthUnavailable>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = HealthUnavailable.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of HealthUnavailable-objects as value to a dart map
  static Map<String, List<HealthUnavailable>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<HealthUnavailable>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = HealthUnavailable.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
    'database',
  };
}


class HealthUnavailableStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const HealthUnavailableStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const unavailable = HealthUnavailableStatusEnum._(r'unavailable');

  /// List of all possible values in this [enum][HealthUnavailableStatusEnum].
  static const values = <HealthUnavailableStatusEnum>[
    unavailable,
  ];

  static HealthUnavailableStatusEnum? fromJson(dynamic value) => HealthUnavailableStatusEnumTypeTransformer().decode(value);

  static List<HealthUnavailableStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HealthUnavailableStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HealthUnavailableStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [HealthUnavailableStatusEnum] to String,
/// and [decode] dynamic data back to [HealthUnavailableStatusEnum].
class HealthUnavailableStatusEnumTypeTransformer {
  factory HealthUnavailableStatusEnumTypeTransformer() => _instance ??= const HealthUnavailableStatusEnumTypeTransformer._();

  const HealthUnavailableStatusEnumTypeTransformer._();

  String encode(HealthUnavailableStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a HealthUnavailableStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  HealthUnavailableStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'unavailable': return HealthUnavailableStatusEnum.unavailable;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [HealthUnavailableStatusEnumTypeTransformer] instance.
  static HealthUnavailableStatusEnumTypeTransformer? _instance;
}



class HealthUnavailableDatabaseEnum {
  /// Instantiate a new enum with the provided [value].
  const HealthUnavailableDatabaseEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const unavailable = HealthUnavailableDatabaseEnum._(r'unavailable');

  /// List of all possible values in this [enum][HealthUnavailableDatabaseEnum].
  static const values = <HealthUnavailableDatabaseEnum>[
    unavailable,
  ];

  static HealthUnavailableDatabaseEnum? fromJson(dynamic value) => HealthUnavailableDatabaseEnumTypeTransformer().decode(value);

  static List<HealthUnavailableDatabaseEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HealthUnavailableDatabaseEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HealthUnavailableDatabaseEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [HealthUnavailableDatabaseEnum] to String,
/// and [decode] dynamic data back to [HealthUnavailableDatabaseEnum].
class HealthUnavailableDatabaseEnumTypeTransformer {
  factory HealthUnavailableDatabaseEnumTypeTransformer() => _instance ??= const HealthUnavailableDatabaseEnumTypeTransformer._();

  const HealthUnavailableDatabaseEnumTypeTransformer._();

  String encode(HealthUnavailableDatabaseEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a HealthUnavailableDatabaseEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  HealthUnavailableDatabaseEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'unavailable': return HealthUnavailableDatabaseEnum.unavailable;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [HealthUnavailableDatabaseEnumTypeTransformer] instance.
  static HealthUnavailableDatabaseEnumTypeTransformer? _instance;
}


