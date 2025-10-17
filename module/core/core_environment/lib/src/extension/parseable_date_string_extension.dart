import 'dart:convert';
import 'dart:developer';

import 'package:core_storage/core_storage.dart';
import 'package:intl/intl.dart';

extension ParseableDateStringExtension on String {
  Future<DateTime?> asDateTime({ConverterCacheManager? manager}) async {
    if (isEmpty) return null;

    /// put supported date format here with the longest format first
    final formats = [
      'yyyy-MM-ddTHH:mm:ss.mmmZ',
      'yyyy-MM-ddTHH:mm:ssZ',
      'MMMM dd yyyy',
      'MM/dd/yyyy',
    ];

    final file = await manager?.getFileFromCache(this);
    final data = await file?.file.readAsString(encoding: utf8);
    final date = DateTime.tryParse(data ?? '');
    if (date != null) return date;

    for (final format in formats) {
      try {
        final result = DateFormat(format).parse(this).toUtc();
        await manager?.putFile(
          this,
          utf8.encode(result.toIso8601String()),
          key: this,
        );
        return result;
      } catch (e) {
        log('$e ($this)', name: 'ParseableDateStringExtension');
      }
    }

    return null;
  }
}
