import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_storage/core_storage.dart';
import 'package:intl/intl.dart';

extension ParseableDateStringExtension on String {
  static final List<DateFormat> _customFormats = [
    DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
    DateFormat('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
    DateFormat('MMMM dd yyyy'),
    DateFormat('MM/dd/yyyy'),
  ];

  Future<DateTime?> asDateTime({
    required LogBox logbox,
    ConverterCacheManager? manager,
  }) {
    return _parseDateTime(manager: manager).then((e) {
      if (e == null) {
        logbox.log(
          'Failed Parsing Date ($this)',
          name: 'ParseableDateStringExtension',
        );
      }

      return e;
    });
  }

  Future<DateTime?> _parseDateTime({ConverterCacheManager? manager}) async {
    if (isEmpty) return null;

    // 1. Try ISO first (Fastest, no I/O needed)
    final isoResult = DateTime.tryParse(this);
    if (isoResult != null) return isoResult;

    // 2. Try Relative Date (e.g., "2 days ago", "Yesterday")
    final relativeDate = _parseRelativeDate(this);
    if (relativeDate != null) return relativeDate;

    // 3. Check Cache
    if (manager != null) {
      final fileInfo = await manager.getFileFromCache(this);
      if (fileInfo != null) {
        // Assuming cache stores the ISO string
        final data = await fileInfo.file.readAsString(encoding: utf8);
        final cachedDate = DateTime.tryParse(data);
        if (cachedDate != null) return cachedDate;
      }
    }

    // 4. Try Custom Formats
    for (final formatter in _customFormats) {
      try {
        final result = formatter.parseStrict(this).toUtc();

        await manager?.putFile(
          this,
          utf8.encode(result.toIso8601String()),
          key: this,
        );

        return result;
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  DateTime? _parseRelativeDate(String input) {
    final lowerInput = input.trim().toLowerCase();

    if (lowerInput == 'yesterday') {
      return DateTime.now().subtract(const Duration(days: 1));
    }
    if (lowerInput == 'today') {
      return DateTime.now();
    }

    final regex = RegExp(
      r'^(\d+)\s+(sec|min|hour|day|week|month|year)[a-z]*\s+ago$',
    );
    final match = regex.firstMatch(lowerInput);

    if (match != null) {
      final amount = int.parse(match.group(1)!);
      final unit = match.group(2)!;
      final now = DateTime.now();

      switch (unit) {
        case 'sec':
          return now.subtract(Duration(seconds: amount));
        case 'min':
          return now.subtract(Duration(minutes: amount));
        case 'hour':
          return now.subtract(Duration(hours: amount));
        case 'day':
          return now.subtract(Duration(days: amount));
        case 'week':
          return now.subtract(Duration(days: amount * 7));
        case 'month':
          return DateTime(now.year, now.month - amount, now.day);
        case 'year':
          return DateTime(now.year - amount, now.month, now.day);
      }
    }

    return null;
  }
}
