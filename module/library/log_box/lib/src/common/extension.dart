import 'dart:convert';

import 'package:intl/intl.dart';

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
  String get dateFormatted {
    return DateFormat('DD-MM-YYYY').format(this);
  }

  String get timeFormatted {
    return DateFormat('hh:mm:ss.s').format(this);
  }

  String get timezoneFormatted {
    return DateFormat('TZD').format(this);
  }
}
