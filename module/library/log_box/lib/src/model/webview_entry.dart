import '../common/enum.dart';
import 'entry.dart';

class WebviewEntry extends Entry {
  final Uri? uri;

  final List<String> scripts;

  final List<WebviewEntryLog> events;

  final String? html;

  final Object? error;

  WebviewEntry({
    String? id,
    DateTime? timestamp,
    this.uri,
    this.scripts = const [],
    this.events = const [],
    this.html,
    this.error,
  }) : super(id: id, timestamp: timestamp);

  WebviewEntry copyWith({
    Uri? uri,
    List<String>? scripts,
    List<WebviewEntryLog>? events,
    String? html,
    Object? error,
  }) {
    return WebviewEntry(
      id: id,
      timestamp: timestamp,
      uri: uri ?? this.uri,
      scripts: scripts ?? this.scripts,
      events: events ?? this.events,
      html: html ?? this.html,
      error: error ?? this.error,
    );
  }
}

class WebviewEntryLog {
  final WebviewEvent event;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  WebviewEntryLog({required this.event, this.extra})
    : timestamp = DateTime.timestamp();
}
