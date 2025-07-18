import 'dart:convert';

import 'package:intl/intl.dart';

extension EncodeRawJsonExtension on dynamic {
  String? get rawJson {
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

extension JsonExtension on String? {
  String get prettify {
    if (this != null) {
      try {
        var decoded = json.decode(this!);
        var encoder = const JsonEncoder.withIndent('  ');
        var prettyJson = encoder.convert(decoded);
        return prettyJson;
      } catch (e) {
        return 'N/A-Cannot Parse';
      }
    }
    return 'N/A';
  }

  bool get isJson {
    try {
      json.decode(this!);
      return true;
    } catch (_) {
      return false;
    }
  }

  String toJson() {
    return json.encode(this);
  }

  Map<String, dynamic> toMap() {
    if (this == null) {
      return <String, dynamic>{};
    }
    return json.decode(this!);
  }
}

extension DateTimeFormatter on DateTime {
  String get dateTimeFormatted {
    return DateFormat('dd-MM-yyyy HH:mm:ss.s').format(toLocal());
  }

  String get dateFormatted {
    return DateFormat('dd-MM-yyyy').format(toLocal());
  }

  String get timeFormatted {
    return DateFormat('hh:mm:ss.s').format(toLocal());
  }
}
