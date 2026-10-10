// Value types of the source registry (issue #115): the resolved view of one
// JavaScript source ([SourceEntry] + [SourceStatus]) and the outcome of
// classifying a script about to be saved ([SaveTarget]).
//
// Usage: obtain entries from `SourceRegistry.entries`; call
// `SourceRegistry.classify(code)` to learn whether saving would create a new
// source or replace an existing one, and switch exhaustively on [SaveTarget].
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';

/// Where a resolved source stands relative to the script bundled with the app.
enum SourceStatus {
  /// No stored row: the bundled script is used as-is.
  shipped,

  /// The user edited a bundled script; the bundled one is not newer.
  modified,

  /// The user edited a bundled script and the bundled one has since moved to a
  /// higher version than the one the edit was forked from.
  updateAvailable,

  /// A script created entirely by the user.
  custom,
}

/// One resolved source: the script in effect, its [status] and, for bundled
/// ids, the bundled script ([shipped]) so the UI can diff or reset to it.
class SourceEntry extends Equatable {
  final SourceScript script;
  final SourceStatus status;
  final SourceScript? shipped;

  const SourceEntry({
    required this.script,
    required this.status,
    this.shipped,
  });

  @override
  List<Object?> get props => [script, status, shipped];
}

/// What saving a script would do.
sealed class SaveTarget {
  const SaveTarget();
}

/// The script's id is unknown: saving creates a custom source.
class NewSource extends SaveTarget {
  const NewSource();
}

/// The script's id matches [entry]: saving replaces it.
class ReplacesSource extends SaveTarget {
  final SourceEntry entry;

  const ReplacesSource(this.entry);
}
