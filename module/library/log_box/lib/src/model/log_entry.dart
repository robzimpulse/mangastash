import 'package:uuid/uuid.dart';

import 'entry.dart';

class LogEntry extends Entry {
  final String message;
  final Map<String, dynamic> extra;
  final DateTime timestamp;

  LogEntry._({
    required super.id,
    required this.message,
    required this.extra,
    required this.timestamp,
  });

  factory LogEntry.create({
    String? id,
    required String message,
    Map<String, dynamic> extra = const {},
  }) {
    return LogEntry._(
      id: id ?? const Uuid().v4(),
      message: message,
      extra: extra,
      timestamp: DateTime.timestamp(),
    );
  }

  LogEntry copyWith({String? message, Map<String, dynamic>? extra}) {
    return LogEntry._(
      id: id,
      timestamp: timestamp,
      message: message ?? this.message,
      extra: extra ?? this.extra,
    );
  }
}
