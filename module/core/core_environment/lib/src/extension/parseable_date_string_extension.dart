import 'dart:developer';

import 'package:intl/intl.dart';

extension ParseableDateStringExtension on String {

  DateTime? get asDateTime {
    /// put supported date format here with the longest format first
    final formats = [
      'yyyy-MM-ddTHH:mm:ss.mmmZ',
      'yyyy-MM-ddTHH:mm:ssZ',
      'MM/dd/yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(this).toUtc();
      } on Exception catch (e) {
        log(e.toString(), name: 'ParseableDateStringExtension');
      }
    }

    return null;
  }
}
