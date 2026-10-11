// SourceEditorScreen: edits one JavaScript source (issue #115, spec §10/§10.1).
// Shows the locked source name read-only, a Test bar (function + search term
// or URL input), the toolbar (Test, Copy fix prompt, Paste answer), the last
// Test result and a plain monospace editor (no syntax highlighting, so long
// scripts stay fast). Save lives in the app bar and asks
// `Test is failing. Save anyway?` after a failing Test; save errors show as a
// banner above the editor. The overflow menu offers `Reset to built-in` for
// modified / update-available sources and `View new version` (read-only
// shipped code) for update-available ones. An unknown id shows an error state.
//
// The editor's TextEditingController lives in this State, so unsaved text
// survives rebuilds. While typing the controller is the source of truth: every
// controller change is pushed to the cubit, and the cubit's code is written
// back only when it differs from the controller's CURRENT text, judged against
// `cubit.state` (never the possibly stale state the listener was handed).
// Writing a stale emission back used to ping-pong with the controller listener
// forever on fast input (UI freeze). An external replacement (Paste answer,
// Reset, View new version, entries refresh) moves the caret to the start, and
// the push-back is suppressed while it is applied (`_syncing`).
//
// Save is disabled while a Test runs and cannot be re-entered while a save
// (or its confirmation) is pending; only a current failing run (same code,
// function and input) asks for confirmation — a stale run counts as untested.
//
// Usage: `SourceEditorScreen.create(locator: locator, id: id,
// function: fn, url: url)`; `function`/`url` prefill Test (e.g. from a
// failure's "Fix source" entry).
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'source_editor_screen_cubit.dart';
import 'source_editor_screen_state.dart';
import 'widget/test_result_panel.dart';

class SourceEditorScreen extends StatefulWidget {
  const SourceEditorScreen({super.key});

  /// Key of the script editor field.
  static const Key editorKey = ValueKey('source-editor-code');

  /// Key of the Test input field.
  static const Key inputKey = ValueKey('source-editor-input');

  static Widget create({
    required ServiceLocator locator,
    required String id,
    String? function,
    String? url,
  }) {
    return BlocProvider(
      create: (context) {
        return SourceEditorScreenCubit(
          id: id,
          function: function,
          url: url,
          registry: locator(),
          runner: locator(),
          promptBuilder: locator(),
        );
      },
      child: const SourceEditorScreen(),
    );
  }

  @override
  State<SourceEditorScreen> createState() => _SourceEditorScreenState();
}

class _SourceEditorScreenState extends State<SourceEditorScreen> {
  late final TextEditingController _code;
  late final TextEditingController _input;

  /// True while a save (or its confirmation dialog) is in progress.
  bool _saving = false;

  /// True while the cubit's code is being written into the controller, so the
  /// controller listener does not echo it back to the cubit.
  bool _syncing = false;

  SourceEditorScreenCubit get _cubit => context.read();

  @override
  void initState() {
    super.initState();
    final state = _cubit.state;
    _code = TextEditingController(text: state.code);
    _input = TextEditingController(text: state.input);
    _code.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    if (_syncing) return;
    _cubit.updateCode(_code.text);
  }

  /// Writes the cubit's current code into the controller when an external
  /// replacement made them differ; a no-op while the controller is ahead.
  void _applyCubitCode() {
    final code = _cubit.state.code;
    if (_code.text == code) return;
    _syncing = true;
    try {
      _code.value = TextEditingValue(
        text: code,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } finally {
      _syncing = false;
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SourceEditorScreenCubit, SourceEditorScreenState>(
          listenWhen: (prev, curr) => prev.message != curr.message,
          listener: (context, state) {
            final message = state.message;
            if (message == null) return;
            context.showSnackBar(message: message);
            _cubit.clearMessage();
          },
        ),
        BlocListener<SourceEditorScreenCubit, SourceEditorScreenState>(
          listenWhen: (prev, curr) => prev.code != curr.code,
          // The handed state may be older than the controller; the latest
          // cubit code is what counts (see the file header).
          listener: (context, state) => _applyCubitCode(),
        ),
      ],
      child: BlocBuilder<SourceEditorScreenCubit, SourceEditorScreenState>(
        builder: (context, state) {
          final entry = state.entry;
          return ScaffoldScreen(
            appBar: AppBar(
              title: const Text('Edit source'),
              actions: [
                if (entry != null)
                  IconButton(
                    tooltip: 'Save',
                    icon: const Icon(Icons.save),
                    onPressed:
                        state.hasChanges && !state.isRunning && !_saving
                            ? () => _onSave(state)
                            : null,
                  ),
                if (entry != null) ..._buildMenu(entry),
              ],
            ),
            body:
                entry == null
                    ? const Center(child: Text('Source not found'))
                    : _buildBody(context, state, entry),
          );
        },
      ),
    );
  }

  List<Widget> _buildMenu(SourceEntry entry) {
    final canReset =
        entry.status == SourceStatus.modified ||
        entry.status == SourceStatus.updateAvailable;
    final shipped = entry.shipped;
    final canView = entry.status == SourceStatus.updateAvailable;
    if (!canReset) return const [];
    return [
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'reset') _onReset(entry);
          if (value == 'view' && shipped != null) _onViewShipped(shipped);
        },
        itemBuilder: (context) {
          return [
            if (canView && shipped != null)
              const PopupMenuItem(
                value: 'view',
                child: Text('View new version'),
              ),
            const PopupMenuItem(
              value: 'reset',
              child: Text('Reset to built-in'),
            ),
          ];
        },
      ),
    ];
  }

  Widget _buildBody(
    BuildContext context,
    SourceEditorScreenState state,
    SourceEntry entry,
  ) {
    final theme = Theme.of(context);
    final lastRun = state.lastRun;
    final saveError = state.saveError;
    final hint = state.hint;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: Text(entry.script.name),
            subtitle: const Text('Name cannot be changed'),
          ),
          _buildTestBar(state),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: state.isRunning ? null : _cubit.test,
                child: const Text('Test'),
              ),
              OutlinedButton(
                onPressed: state.isRunning ? null : _cubit.copyFixPrompt,
                child: const Text('Copy fix prompt'),
              ),
              OutlinedButton(
                onPressed: _cubit.pasteAnswer,
                child: const Text('Paste answer'),
              ),
            ],
          ),
          if (state.isRunning) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          if (lastRun != null) ...[
            const SizedBox(height: 12),
            TestResultPanel(run: lastRun),
          ],
          if (saveError != null) ...[
            const SizedBox(height: 12),
            _Banner(text: saveError, color: theme.colorScheme.errorContainer),
          ],
          if (hint != null) ...[
            const SizedBox(height: 12),
            _Banner(text: hint, color: theme.colorScheme.secondaryContainer),
          ],
          const SizedBox(height: 12),
          TextField(
            key: SourceEditorScreen.editorKey,
            controller: _code,
            maxLines: null,
            minLines: 12,
            keyboardType: TextInputType.multiline,
            autocorrect: false,
            enableSuggestions: false,
            smartQuotesType: SmartQuotesType.disabled,
            smartDashesType: SmartDashesType.disabled,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildTestBar(SourceEditorScreenState state) {
    final label = switch (state.function) {
      'search' => 'Search term or URL',
      'tags' => 'URL (optional)',
      _ => 'Page URL',
    };
    return Row(
      children: [
        DropdownButton<String>(
          value: state.function,
          onChanged: (value) {
            if (value != null) _cubit.selectFunction(value);
          },
          items: [
            for (final function in SourceEditorScreenCubit.functions)
              DropdownMenuItem(value: function, child: Text(function)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            key: SourceEditorScreen.inputKey,
            controller: _input,
            autocorrect: false,
            enableSuggestions: false,
            smartQuotesType: SmartQuotesType.disabled,
            smartDashesType: SmartDashesType.disabled,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: label),
            onChanged: _cubit.updateInput,
          ),
        ),
      ],
    );
  }

  Future<bool> _confirm({
    required String title,
    required String confirmText,
    String? content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: content == null ? null : Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _onSave(SourceEditorScreenState state) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (state.currentRun?.failed ?? false) {
        final confirmed = await _confirm(
          title: 'Test is failing. Save anyway?',
          confirmText: 'Save',
        );
        if (!confirmed || !mounted) return;
      }
      await _cubit.save();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onReset(SourceEntry entry) async {
    final confirmed = await _confirm(
      title: 'Reset ${entry.script.name}?',
      content:
          'Your changes are discarded and the built-in script is restored.',
      confirmText: 'Reset',
    );
    if (!confirmed || !mounted) return;
    await _cubit.reset();
  }

  Future<void> _onViewShipped(SourceScript shipped) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Version ${shipped.version}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                shipped.code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

/// A full-width coloured message box (save error or hint).
class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: Text(text)),
    );
  }
}
