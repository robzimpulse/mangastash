/// Internal helpers for the hand-written `fromJson` factories of the
/// `*Scrapped` models.
///
/// Usage: `optionalString(json, 'title')` returns the value or null when the
/// key is absent/null, and throws a [FormatException] naming the field when the
/// value has the wrong type. Not exported from the package barrel.
library;

/// Reads an optional string field; throws [FormatException] naming [key] on a
/// wrong type.
String? optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException(
    'Field "$key" must be a string, got ${value.runtimeType}',
  );
}

/// Reads an optional bool field; throws [FormatException] naming [key] on a
/// wrong type.
bool? optionalBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is bool) return value;
  throw FormatException(
    'Field "$key" must be a boolean, got ${value.runtimeType}',
  );
}

/// Reads an optional list-of-strings field; throws [FormatException] naming
/// [key] when the value is not a list or any element is not a string.
List<String>? optionalStringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is List && value.every((e) => e is String)) {
    return List<String>.from(value);
  }
  throw FormatException('Field "$key" must be a list of strings');
}

/// Reads an optional list-of-objects field; throws [FormatException] naming
/// [key] when the value is not a list or any element is not a JSON object.
List<Map<String, dynamic>>? optionalObjectList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value == null) return null;
  if (value is List && value.every((e) => e is Map)) {
    return [for (final e in value) Map<String, dynamic>.from(e as Map)];
  }
  throw FormatException('Field "$key" must be a list of objects');
}
