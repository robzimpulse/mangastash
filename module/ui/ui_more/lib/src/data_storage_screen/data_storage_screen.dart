import 'package:core_storage/core_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart' hide Error;
import 'package:universal_io/universal_io.dart';

import 'data_storage_screen_cubit.dart';
import 'data_storage_screen_state.dart';

class DataStorageScreen extends StatelessWidget {
  const DataStorageScreen({
    super.key,
    required this.filesystemPickerUseCase,
    this.onUpdateRootPathConfirmation,
    this.onRestoreBackupConfirmation,
    this.onDeleteBackupConfirmation,
  });

  final FilesystemPickerUseCase filesystemPickerUseCase;

  final AsyncValueGetter<bool?>? onUpdateRootPathConfirmation;

  final AsyncValueGetter<bool?>? onRestoreBackupConfirmation;

  final AsyncValueGetter<bool?>? onDeleteBackupConfirmation;

  static Widget create({
    required ServiceLocator locator,
    required AsyncValueGetter<bool?>? onUpdateRootPathConfirmation,
    required AsyncValueGetter<bool?>? onRestoreBackupConfirmation,
    required AsyncValueGetter<bool?>? onDeleteBackupConfirmation,
  }) {
    return BlocProvider(
      create: (context) {
        return DataStorageScreenCubit(
          database: locator(),
          getBackupPathUseCase: locator(),
        )..refreshListBackup();
      },
      child: DataStorageScreen(
        filesystemPickerUseCase: locator(),
        onUpdateRootPathConfirmation: onUpdateRootPathConfirmation,
        onRestoreBackupConfirmation: onRestoreBackupConfirmation,
        onDeleteBackupConfirmation: onDeleteBackupConfirmation,
      ),
    );
  }

  DataStorageScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<DataStorageScreenState> builder,
    BlocBuilderCondition<DataStorageScreenState>? buildWhen,
  }) {
    return BlocBuilder<DataStorageScreenCubit, DataStorageScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(title: const Text('Data and Storage')),
      body: ListView(
        children: [
          if (!kIsWeb) ...[
            _buildBackupRestoreSection(context),
          ] else ...[
            Center(child: Text('This feature were unsupported on Web')),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupRestoreSection(BuildContext context) {
    return ExpansionTile(
      title: Text('Backup and Restore'),
      subtitle: Text(
        'You should keep copies of backups in other places as well.',
      ),
      leading: Icon(Icons.restore),
      children: [
        _builder(
          buildWhen: (prev, curr) {
            return prev.isLoadingBackup != curr.isLoadingBackup;
          },
          builder: (context, state) {
            Widget trailing;

            if (state.isLoadingBackup) {
              trailing = SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              );
            } else {
              trailing = PopupMenuButton<_AddBackupMenuOption>(
                icon: Icon(Icons.add),
                onSelected: (value) {
                  switch (value) {
                    case _AddBackupMenuOption.fromExternalFile:
                      _onTapAddBackupFromExternal(context);
                    case _AddBackupMenuOption.fromDatabase:
                      _onTapBackupNow(context);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<_AddBackupMenuOption>(
                      value: _AddBackupMenuOption.fromDatabase,
                      child: Text('From Database'),
                    ),
                    PopupMenuItem<_AddBackupMenuOption>(
                      value: _AddBackupMenuOption.fromExternalFile,
                      child: Text('From File'),
                    ),
                  ];
                },
              );
            }

            return ListTile(
              title: Text('List of Backup Data'),
              trailing: trailing,
            );
          },
        ),
        _builder(
          buildWhen: (prev, curr) => prev.listBackup != curr.listBackup,
          builder: (context, state) {
            if (state.listBackup.isEmpty) {
              return SizedBox(
                height: 50,
                child: Center(child: Text('No backup data')),
              );
            }

            return Column(
              children: [
                for (final file in state.listBackup.reversed)
                  ListTile(
                    title: Text(file.filename ?? 'Unknown'),
                    subtitle: FutureBuilder(
                      future: file.stat(),
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        if (data == null) return SizedBox.shrink();

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Modified: ${data.modified.toString()}'),
                            Text('Size: ${data.sizeInKb} KB'),
                          ],
                        );
                      },
                    ),
                    trailing: PopupMenuButton<_MenuOption>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case _MenuOption.share:
                            _onTapShareBackup(context, file);
                          case _MenuOption.restore:
                            _onTapRestoreBackup(context, file);
                          case _MenuOption.delete:
                            _onTapDeleteBackup(context, file);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem<_MenuOption>(
                            value: _MenuOption.restore,
                            child: Text('Restore'),
                          ),
                          PopupMenuItem<_MenuOption>(
                            value: _MenuOption.share,
                            child: Text('Share'),
                          ),
                          PopupMenuItem<_MenuOption>(
                            value: _MenuOption.delete,
                            child: Text('Delete'),
                          ),
                        ];
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _onTapDeleteBackup(BuildContext context, FileSystemEntity file) async {
    final confirm = await onDeleteBackupConfirmation?.call();
    if (!context.mounted || confirm != true) return;
    await _cubit(context).deleteBackup(file);
    if (!context.mounted) return;
    context.showSnackBar(message: 'Success delete backup');
  }

  void _onTapShareBackup(BuildContext context, FileSystemEntity file) async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
    if (!context.mounted) return;
    switch (result.status) {
      case ShareResultStatus.success:
        context.showSnackBar(message: 'Success share backup database');
      case ShareResultStatus.dismissed:
        context.showSnackBar(message: 'Cancel share backup database');
      case ShareResultStatus.unavailable:
        context.showSnackBar(message: 'Failed share backup database');
    }
  }

  void _onTapRestoreBackup(BuildContext context, FileSystemEntity file) async {
    final confirm = await onRestoreBackupConfirmation?.call();
    if (!context.mounted || confirm != true) return;
    await _cubit(context).restoreBackup(File(file.path));
    if (!context.mounted) return;
    context.showSnackBar(message: 'Success restore backup');
    WrapperScreen.restart(context);
  }

  void _onTapAddBackupFromExternal(BuildContext context) async {
    final file = await filesystemPickerUseCase.file(context);
    if (!context.mounted || file == null) return;
    _cubit(context).addBackupFromFile(file);
  }

  void _onTapBackupNow(BuildContext context) async {
    await _cubit(context).addBackup();
    if (!context.mounted) return;
    context.showSnackBar(message: 'Success adding backup');
  }
}

enum _MenuOption { share, restore, delete }

enum _AddBackupMenuOption { fromExternalFile, fromDatabase }
