import 'dart:developer';

import 'package:intl/intl.dart';

extension ParseableDateStringExtension on String {

  DateTime? get asDateTime {
    /// put supported date format here with the longest format first
    final formats = [
      'yyyy-MM-ddTHH:mm:ss.mmmZ',
      'yyyy-MM-ddTHH:mm:ssZ',
      'MMMM dd yyyy',
      'MM/dd/yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(this).toUtc();
      } catch (e) {
        log('$e', name: 'ParseableDateStringExtension');
      }
    }

    return null;
  }
}
