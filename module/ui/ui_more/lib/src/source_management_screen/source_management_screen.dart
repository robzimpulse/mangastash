import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'source_management_screen_cubit.dart';
import 'source_management_screen_state.dart';

class SourceManagementScreen extends StatelessWidget {
  final Function(DynamicSourceDrift?) onTapEdit;

  const SourceManagementScreen({super.key, required this.onTapEdit});

  static Widget create({required ServiceLocator locator, required Function(DynamicSourceDrift?) onTapEdit}) {
    return BlocProvider(
      create: (context) => SourceManagementScreenCubit(
        dynamicSourceDao: locator(),
        importDynamicSourceUseCase: locator(),
        deleteDynamicSourceUseCase: locator(),
        toggleDynamicSourceUseCase: locator(),
      ),
      child: SourceManagementScreen(onTapEdit: onTapEdit),
    );
  }

  SourceManagementScreenCubit? _cubit(BuildContext context) {
    return context.mounted ? context.read() : null;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Manage Dynamic Sources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showImportDialog(context),
            tooltip: 'Import from URL',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onTapEdit(null),
            tooltip: 'Create New Source',
          ),
        ],
      ),
      body: BlocBuilder<SourceManagementScreenCubit, SourceManagementScreenState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.dynamicSources.isEmpty) {
            return const Center(child: Text('No dynamic sources added.'));
          }

          return AdaptivePhysicListView(
            children: state.dynamicSources.map((source) {
              return ListTile(
                title: Text(source.name),
                subtitle: Text(source.baseUrl),
                leading: const Icon(Icons.code),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: source.isActive,
                      onChanged: (value) => _cubit(context)?.toggleSource(source.id, value),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _cubit(context)?.deleteSource(source.id),
                    ),
                  ],
                ),
                onTap: () => onTapEdit(source),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter script URL'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _cubit(context)?.importFromUrl(controller.text);
              Navigator.pop(dialogContext);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
