// SourceListScreenState: immutable state of the source list screen (issue #115)
// — the registry's script entries, the built-in source names (MangaDex), the
// names of the enabled sources and a one-shot user-facing message.
//
// Usage: `state.copyWith(entries: ...)`; set `message` to publish a snackbar
// text and `clearMessage: true` once it was shown.
import 'package:domain_manga/domain_manga.dart';
import 'package:equatable/equatable.dart';

class SourceListScreenState extends Equatable {
  /// Script sources in registry order (shipped first, then custom by name).
  final List<SourceEntry> entries;

  /// Names of the native sources that have no script (MangaDex): toggle only.
  final List<String> builtInNames;

  /// Names of the sources currently enabled.
  final Set<String> enabledNames;

  /// One-shot message for a snackbar; null when there is nothing to show.
  final String? message;

  const SourceListScreenState({
    this.entries = const [],
    this.builtInNames = const [],
    this.enabledNames = const {},
    this.message,
  });

  @override
  List<Object?> get props => [entries, builtInNames, enabledNames, message];

  SourceListScreenState copyWith({
    List<SourceEntry>? entries,
    List<String>? builtInNames,
    Set<String>? enabledNames,
    String? message,
    bool clearMessage = false,
  }) {
    return SourceListScreenState(
      entries: entries ?? this.entries,
      builtInNames: builtInNames ?? this.builtInNames,
      enabledNames: enabledNames ?? this.enabledNames,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
