//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// The currency the Center bills in.
class Currency {
  /// Instantiate a new enum with the provided [value].
  const Currency._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const USD = Currency._(r'USD');
  static const CAD = Currency._(r'CAD');

  /// List of all possible values in this [enum][Currency].
  static const values = <Currency>[
    USD,
    CAD,
  ];

  static Currency? fromJson(dynamic value) => CurrencyTypeTransformer().decode(value);

  static List<Currency> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Currency>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Currency.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [Currency] to String,
/// and [decode] dynamic data back to [Currency].
class CurrencyTypeTransformer {
  factory CurrencyTypeTransformer() => _instance ??= const CurrencyTypeTransformer._();

  const CurrencyTypeTransformer._();

  String encode(Currency data) => data.value;

  /// Decodes a [dynamic value][data] to a Currency.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  Currency? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'USD': return Currency.USD;
        case r'CAD': return Currency.CAD;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CurrencyTypeTransformer] instance.
  static CurrencyTypeTransformer? _instance;
}

