// SourceEditorScreenState: immutable state of the source editor (issue #115,
// spec §10) — the edited source's entry (null when the id is unknown), the
// unsaved [code] and the last saved [savedCode], the Test function and input,
// the outcome of the last Test ([SourceTestRun]), plus the one-shot snackbar
// [message], the persistent [hint] and the Save error [saveError].
//
// Usage: `state.copyWith(code: ...)`; nullable fields are cleared with the
// matching `clearX: true` flag. [SourceTestRun.failed] tells whether Save
// must ask for confirmation.
import 'package:domain_manga/domain_manga.dart';
import 'package:equatable/equatable.dart';

/// Outcome of one Test run against the unsaved script.
class SourceTestRun extends Equatable {
  /// The script function that was tested.
  final String function;

  /// The page URL the function ran on; null when the run stopped before.
  final String? url;

  /// The function's result as pretty JSON, cut to the first 200 lines.
  final String? json;

  /// Script, header or runtime error; null when the script ran.
  final String? error;

  /// 1-based script line of [error], when the runtime knows it.
  final int? line;

  /// Domain validation failure (e.g. `missing title`); null when it passed.
  final String? validation;

  /// Short summary of a passing run, e.g. `Valid — 12 items`.
  final String? summary;

  /// Wall time of the whole run.
  final Duration elapsed;

  /// Page HTML as the webview saw it, for the fix prompt.
  final String? html;

  const SourceTestRun({
    required this.function,
    required this.elapsed,
    this.url,
    this.json,
    this.error,
    this.line,
    this.validation,
    this.summary,
    this.html,
  });

  /// Whether the run errored or its result failed validation.
  bool get failed => error != null || validation != null;

  /// The error or validation message (with the line), or null when it passed.
  String? get problem {
    final error = this.error;
    if (error != null) return line == null ? error : 'line $line: $error';
    return validation;
  }

  @override
  List<Object?> get props => [
    function,
    url,
    json,
    error,
    line,
    validation,
    summary,
    elapsed,
    html,
  ];
}

class SourceEditorScreenState extends Equatable {
  /// Id of the edited source.
  final String id;

  /// The registry entry for [id]; null when no source has that id.
  final SourceEntry? entry;

  /// The editor text, possibly unsaved.
  final String code;

  /// The script as last stored (or loaded).
  final String savedCode;

  /// Function run by Test.
  final String function;

  /// Test input: a search term or a URL.
  final String input;

  /// Outcome of the last Test, if any.
  final SourceTestRun? lastRun;

  /// Whether a Test (or the Test behind Copy fix prompt) is running.
  final bool isRunning;

  /// Persistent hint shown above the editor, e.g. `Run Test before saving`.
  final String? hint;

  /// Why the last Save failed; shown as a banner.
  final String? saveError;

  /// One-shot message for a snackbar.
  final String? message;

  const SourceEditorScreenState({
    required this.id,
    this.entry,
    this.code = '',
    this.savedCode = '',
    this.function = 'search',
    this.input = '',
    this.lastRun,
    this.isRunning = false,
    this.hint,
    this.saveError,
    this.message,
  });

  /// Whether [code] differs from [savedCode].
  bool get hasChanges => code != savedCode;

  @override
  List<Object?> get props => [
    id,
    entry,
    code,
    savedCode,
    function,
    input,
    lastRun,
    isRunning,
    hint,
    saveError,
    message,
  ];

  SourceEditorScreenState copyWith({
    SourceEntry? entry,
    bool clearEntry = false,
    String? code,
    String? savedCode,
    String? function,
    String? input,
    SourceTestRun? lastRun,
    bool? isRunning,
    String? hint,
    bool clearHint = false,
    String? saveError,
    bool clearSaveError = false,
    String? message,
    bool clearMessage = false,
  }) {
    return SourceEditorScreenState(
      id: id,
      entry: clearEntry ? null : (entry ?? this.entry),
      code: code ?? this.code,
      savedCode: savedCode ?? this.savedCode,
      function: function ?? this.function,
      input: input ?? this.input,
      lastRun: lastRun ?? this.lastRun,
      isRunning: isRunning ?? this.isRunning,
      hint: clearHint ? null : (hint ?? this.hint),
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
