//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Health {
  /// Returns a new [Health] instance.
  Health({
    required this.status,
    required this.database,
    required this.time,
  });

  HealthStatusEnum status;

  /// Whether the API could read the main table.
  HealthDatabaseEnum database;

  /// The server's current time.
  DateTime time;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Health &&
    other.status == status &&
    other.database == database &&
    other.time == time;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode) +
    (database.hashCode) +
    (time.hashCode);

  @override
  String toString() => 'Health[status=$status, database=$database, time=$time]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
      json[r'database'] = this.database;
      json[r'time'] = this.time.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Health] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Health? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Health[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Health[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Health(
        status: HealthStatusEnum.fromJson(json[r'status'])!,
        database: HealthDatabaseEnum.fromJson(json[r'database'])!,
        time: mapDateTime(json, r'time', r'')!,
      );
    }
    return null;
  }

  static List<Health> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Health>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Health.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Health> mapFromJson(dynamic json) {
    final map = <String, Health>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Health.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Health-objects as value to a dart map
  static Map<String, List<Health>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Health>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Health.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
    'database',
    'time',
  };
}


class HealthStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const HealthStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const ok = HealthStatusEnum._(r'ok');

  /// List of all possible values in this [enum][HealthStatusEnum].
  static const values = <HealthStatusEnum>[
    ok,
  ];

  static HealthStatusEnum? fromJson(dynamic value) => HealthStatusEnumTypeTransformer().decode(value);

  static List<HealthStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HealthStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HealthStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [HealthStatusEnum] to String,
/// and [decode] dynamic data back to [HealthStatusEnum].
class HealthStatusEnumTypeTransformer {
  factory HealthStatusEnumTypeTransformer() => _instance ??= const HealthStatusEnumTypeTransformer._();

  const HealthStatusEnumTypeTransformer._();

  String encode(HealthStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a HealthStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  HealthStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'ok': return HealthStatusEnum.ok;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [HealthStatusEnumTypeTransformer] instance.
  static HealthStatusEnumTypeTransformer? _instance;
}


/// Whether the API could read the main table.
class HealthDatabaseEnum {
  /// Instantiate a new enum with the provided [value].
  const HealthDatabaseEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const ok = HealthDatabaseEnum._(r'ok');

  /// List of all possible values in this [enum][HealthDatabaseEnum].
  static const values = <HealthDatabaseEnum>[
    ok,
  ];

  static HealthDatabaseEnum? fromJson(dynamic value) => HealthDatabaseEnumTypeTransformer().decode(value);

  static List<HealthDatabaseEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HealthDatabaseEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HealthDatabaseEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [HealthDatabaseEnum] to String,
/// and [decode] dynamic data back to [HealthDatabaseEnum].
class HealthDatabaseEnumTypeTransformer {
  factory HealthDatabaseEnumTypeTransformer() => _instance ??= const HealthDatabaseEnumTypeTransformer._();

  const HealthDatabaseEnumTypeTransformer._();

  String encode(HealthDatabaseEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a HealthDatabaseEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  HealthDatabaseEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'ok': return HealthDatabaseEnum.ok;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [HealthDatabaseEnumTypeTransformer] instance.
  static HealthDatabaseEnumTypeTransformer? _instance;
}


