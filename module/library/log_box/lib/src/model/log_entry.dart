import 'package:uuid/uuid.dart';

import 'entry.dart';

class LogEntry extends Entry {
  final String message;
  final String? name;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic> extra;
  final DateTime timestamp;

  LogEntry._({
    required super.id,
    required this.message,
    required this.extra,
    required this.timestamp,
    this.name,
    this.error,
    this.stackTrace,
  });

  factory LogEntry.create({
    String? id,
    required String message,
    String? name,
    Map<String, dynamic> extra = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    return LogEntry._(
      id: id ?? const Uuid().v4(),
      message: message,
      name: name,
      extra: extra,
      timestamp: DateTime.timestamp(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  LogEntry copyWith({
    String? message,
    String? name,
    Map<String, dynamic>? extra,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return LogEntry._(
      id: id,
      timestamp: timestamp,
      name: name ?? this.name,
      message: message ?? this.message,
      extra: extra ?? this.extra,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}
