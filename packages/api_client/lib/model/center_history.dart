//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CenterHistory {
  /// Returns a new [CenterHistory] instance.
  CenterHistory({
    this.versions = const [],
  });

  List<CenterVersion> versions;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CenterHistory &&
    _deepEquality.equals(other.versions, versions);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (versions.hashCode);

  @override
  String toString() => 'CenterHistory[versions=$versions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'versions'] = this.versions;
    return json;
  }

  /// Returns a new [CenterHistory] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CenterHistory? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CenterHistory[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CenterHistory[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CenterHistory(
        versions: CenterVersion.listFromJson(json[r'versions']),
      );
    }
    return null;
  }

  static List<CenterHistory> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CenterHistory>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CenterHistory.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CenterHistory> mapFromJson(dynamic json) {
    final map = <String, CenterHistory>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CenterHistory.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CenterHistory-objects as value to a dart map
  static Map<String, List<CenterHistory>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CenterHistory>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CenterHistory.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'versions',
  };
}

