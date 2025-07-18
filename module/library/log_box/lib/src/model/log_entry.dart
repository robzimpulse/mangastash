import 'package:uuid/uuid.dart';

import 'entry.dart';

class LogEntry extends Entry {
  final String message;
  final String? name;
  final Object? error;
  final Map<String, dynamic> extra;
  final DateTime timestamp;

  LogEntry._({
    required super.id,
    required this.message,
    required this.extra,
    required this.timestamp,
    this.name,
    this.error,
  });

  factory LogEntry.create({
    String? id,
    required String message,
    String? name,
    Map<String, dynamic> extra = const {},
    Object? error,
  }) {
    return LogEntry._(
      id: id ?? const Uuid().v4(),
      message: message,
      name: name,
      extra: extra,
      timestamp: DateTime.timestamp(),
      error: error,
    );
  }

  LogEntry copyWith({
    String? message,
    String? name,
    Map<String, dynamic>? extra,
    Object? error,
  }) {
    return LogEntry._(
      id: id,
      timestamp: timestamp,
      name: name ?? this.name,
      message: message ?? this.message,
      extra: extra ?? this.extra,
      error: error ?? this.error,
    );
  }
}
