import 'entry.dart';

class LogEntry extends Entry {
  final String message;
  final Map<String, String> extra;
  final DateTime timestamp;

  LogEntry({
    required super.id,
    required this.message,
    this.extra = const {},
  }): timestamp = DateTime.timestamp();
}