// SourceListScreen: lists the manga sources (issue #115, spec §8) — MangaDex
// with a toggle only, and every script source with its name, a status chip
// (Built-in / Modified / Update available / Custom) and an enable toggle.
// Tapping a script row calls [onTapEdit] with the source id; the overflow menu
// offers "Reset to built-in" (modified / update available) and "Delete"
// (custom), each behind a confirmation. The app-bar "Add source" action reads
// the clipboard and shows a trust dialog before saving.
//
// Usage: `SourceListScreen.create(locator: locator, onTapEdit: (id) => ...)`.
// The editor screen itself is a separate route owned by the caller.
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'source_list_screen_cubit.dart';
import 'source_list_screen_state.dart';

class SourceListScreen extends StatelessWidget {
  const SourceListScreen({super.key, required this.onTapEdit});

  /// Opens the editor for the source with the given id.
  final ValueSetter<String> onTapEdit;

  static const String trustCopy =
      "Scripts run inside the site's page and can contact any website. "
      'Only add scripts you trust.';

  static Widget create({
    required ServiceLocator locator,
    required ValueSetter<String> onTapEdit,
  }) {
    return BlocProvider(
      create: (context) {
        return SourceListScreenCubit(
          registry: locator(),
          listenSourcesUseCase: locator(),
          updateSourcesUseCase: locator(),
        );
      },
      child: SourceListScreen(onTapEdit: onTapEdit),
    );
  }

  SourceListScreenCubit? _cubit(BuildContext context) {
    return context.mounted ? context.read() : null;
  }

  BlocBuilder _builder({
    required BlocWidgetBuilder<SourceListScreenState> builder,
    BlocBuilderCondition<SourceListScreenState>? buildWhen,
  }) {
    return BlocBuilder<SourceListScreenCubit, SourceListScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SourceListScreenCubit, SourceListScreenState>(
      listenWhen: (prev, curr) => prev.message != curr.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        context.showSnackBar(message: message);
        _cubit(context)?.clearMessage();
      },
      child: ScaffoldScreen(
        appBar: AppBar(
          title: const Text('Sources'),
          actions: [
            IconButton(
              tooltip: 'Add source',
              icon: const Icon(Icons.add),
              onPressed: () => _onAdd(context),
            ),
          ],
        ),
        body: _builder(
          builder: (context, state) {
            return AdaptivePhysicListView(
              children: [
                for (final name in state.builtInNames)
                  _buildBuiltIn(context, state, name),
                for (final entry in state.entries)
                  _buildEntry(context, state, entry),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBuiltIn(
    BuildContext context,
    SourceListScreenState state,
    String name,
  ) {
    return ListTile(
      leading: const Icon(Icons.source),
      title: Text(name),
      trailing: _buildSwitch(context, state, name),
    );
  }

  Widget _buildEntry(
    BuildContext context,
    SourceListScreenState state,
    SourceEntry entry,
  ) {
    final script = entry.script;
    return ListTile(
      leading: const Icon(Icons.javascript),
      title: Text(script.name),
      subtitle: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          label: Text(_statusLabel(entry.status)),
          visualDensity: VisualDensity.compact,
        ),
      ),
      onTap: () => onTapEdit(script.id),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenu(context, entry),
          _buildSwitch(context, state, script.name),
        ],
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context,
    SourceListScreenState state,
    String name,
  ) {
    return Switch(
      value: state.enabledNames.contains(name),
      onChanged: (value) => _cubit(context)?.toggle(name: name, enabled: value),
    );
  }

  Widget _buildMenu(BuildContext context, SourceEntry entry) {
    final canReset =
        entry.status == SourceStatus.modified ||
        entry.status == SourceStatus.updateAvailable;
    final canDelete = entry.status == SourceStatus.custom;
    if (!canReset && !canDelete) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'reset') _onReset(context, entry);
        if (value == 'delete') _onDelete(context, entry);
      },
      itemBuilder: (context) {
        return [
          if (canReset)
            const PopupMenuItem(
              value: 'reset',
              child: Text('Reset to built-in'),
            ),
          if (canDelete)
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ];
      },
    );
  }

  static String _statusLabel(SourceStatus status) {
    return switch (status) {
      SourceStatus.shipped => 'Built-in',
      SourceStatus.modified => 'Modified',
      SourceStatus.updateAvailable => 'Update available',
      SourceStatus.custom => 'Custom',
    };
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required List<Widget> content,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
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

  Future<void> _onReset(BuildContext context, SourceEntry entry) async {
    final name = entry.script.name;
    final confirmed = await _confirm(
      context,
      title: 'Reset $name?',
      content: const [
        Text('Your changes are discarded and the built-in script is restored.'),
      ],
      confirmText: 'Reset',
    );
    if (!confirmed || !context.mounted) return;
    await _cubit(context)?.reset(id: entry.script.id);
  }

  Future<void> _onDelete(BuildContext context, SourceEntry entry) async {
    final name = entry.script.name;
    final confirmed = await _confirm(
      context,
      title: 'Delete source',
      content: [
        Text(
          'Delete $name? Its library, history and chapters are kept and come '
          'back if you add a source with the same name.',
        ),
      ],
      confirmText: 'Delete',
    );
    if (!confirmed || !context.mounted) return;
    await _cubit(context)?.delete(id: entry.script.id, name: name);
  }

  Future<void> _onAdd(BuildContext context) async {
    final pending = await _cubit(context)?.inspectClipboard();
    if (pending == null || !context.mounted) return;
    final replaces = pending.replaces;
    final script = pending.script;
    final confirmed = await _confirm(
      context,
      title: replaces == null ? 'Add source' : 'Replace ${script.name}?',
      content: [
        Text(script.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Can contact:'),
        for (final host in script.hosts) Text(host),
        const SizedBox(height: 12),
        const Text(trustCopy),
      ],
      confirmText: replaces == null ? 'Add' : 'Replace',
    );
    if (!confirmed || !context.mounted) return;
    await _cubit(context)?.add(pending);
  }
}
