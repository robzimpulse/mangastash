import 'dart:developer';

import 'package:core_storage/core_storage.dart';
import 'package:intl/intl.dart';

extension ParseableDateStringExtension on String {

  Future<DateTime?> asDateTime({StorageManager? storageManager}) async {
    if (isEmpty) return null;

    /// put supported date format here with the longest format first
    final formats = [
      'yyyy-MM-ddTHH:mm:ss.mmmZ',
      'yyyy-MM-ddTHH:mm:ssZ',
      'MMMM dd yyyy',
      'MM/dd/yyyy',
    ];

    final cached = await storageManager?.converter.get(this);
    if (cached != null) {
      return cached;
    }

    for (final format in formats) {
      try {
        final result = DateFormat(format).parse(this).toUtc();
        await storageManager?.converter.put(this, result);
        return result;
      } catch (e) {
        log('$e ($this)', name: 'ParseableDateStringExtension');
      }
    }

    return null;
  }
}
