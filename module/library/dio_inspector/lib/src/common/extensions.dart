import 'dart:convert';

extension EncodeRawJson on dynamic {
  String? get encodeRawJson {
    if (this == null) return null;

    if (this is Map<String, dynamic>) {
      return (this.isNotEmpty) ? json.encode(this) : null;
    } else if (this is List<dynamic>) {
      return (this.isNotEmpty) ? json.encode(this) : null;
    }
    if (this is String) {
      return this.isNotEmpty ? this : null;
    } else {
      return toString();
    }
  }
}