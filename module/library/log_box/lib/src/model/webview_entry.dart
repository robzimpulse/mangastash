import 'entry.dart';

class WebviewEntry extends Entry {
  final String uri;

  final List<String> scripts;

  final List<WebviewEntryLog> events;

  final DateTime timestamp;

  WebviewEntry({
    required super.id,
    required this.uri,
    this.scripts = const [],
    this.events = const [],
  }) : timestamp = DateTime.timestamp();

  WebviewEntry copyWith({
    List<String>? scripts,
    List<WebviewEntryLog>? events,
  }) {
    return WebviewEntry(
      id: id,
      uri: uri,
      scripts: scripts ?? this.scripts,
      events: events ?? this.events,
    );
  }
}

class WebviewEntryLog {
  final String message;
  final DateTime timestamp;

  WebviewEntryLog({required this.message}) : timestamp = DateTime.timestamp();
}
