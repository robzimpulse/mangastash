import 'package:uuid/uuid.dart';

import 'entry.dart';

class LogEntry extends Entry {
  final String message;
  final Object? error;
  final Map<String, dynamic> extra;
  final DateTime timestamp;

  LogEntry._({
    required super.id,
    required this.message,
    required this.extra,
    required this.timestamp,
    this.error,
  });

  factory LogEntry.create({
    String? id,
    required String message,
    Map<String, dynamic> extra = const {},
    Object? error,
  }) {
    return LogEntry._(
      id: id ?? const Uuid().v4(),
      message: message,
      extra: extra,
      timestamp: DateTime.timestamp(),
      error: error,
    );
  }

  LogEntry copyWith({
    String? message,
    Map<String, dynamic>? extra,
    Object? error,
  }) {
    return LogEntry._(
      id: id,
      timestamp: timestamp,
      message: message ?? this.message,
      extra: extra ?? this.extra,
      error: error ?? this.error,
    );
  }
}
