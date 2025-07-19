import 'entry.dart';

class LogEntry extends Entry {
  final String message;
  final String? name;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic> extra;

  LogEntry({
    String? id,
    DateTime? timestamp,
    required this.message,
    this.extra = const {},
    this.name,
    this.error,
    this.stackTrace,
  }) : super(id: id, timestamp: timestamp);

  LogEntry copyWith({
    String? message,
    String? name,
    Map<String, dynamic>? extra,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return LogEntry(
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
