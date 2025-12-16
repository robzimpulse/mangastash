import 'package:core_storage/core_storage.dart';
import 'package:file/file.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart' hide Error;

import 'data_storage_screen_cubit.dart';
import 'data_storage_screen_state.dart';

class DataStorageScreen extends StatelessWidget {
  const DataStorageScreen({
    super.key,
    required this.imageCacheManager,
    required this.fileSaverUseCase,
    required this.filePickerUseCase,
    this.onUpdateRootPathConfirmation,
    this.onRestoreBackupConfirmation,
    this.onDeleteBackupConfirmation,
  });

  final ImagesCacheManager imageCacheManager;

  final FileSaverUseCase fileSaverUseCase;

  final FilePickerUseCase filePickerUseCase;

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
        fileSaverUseCase: locator(),
        filePickerUseCase: locator(),
        imageCacheManager: locator(),
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
          _buildImageCacheSize(context),
          _buildBackupRestoreSection(context),
        ],
      ),
    );
  }

  Widget _buildImageCacheSize(BuildContext context) {
    return ListTile(
      title: const Text('Image Cache Size'),
      subtitle: FutureBuilder(
        future: imageCacheManager.getSize(),
        builder: (context, snapshot) {
          return Text('Size: ${snapshot.data?.formattedSize}');
        },
      ),
      trailing: IconButton(
        onPressed: () => imageCacheManager.emptyCache(),
        icon: Icon(Icons.delete),
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
                            Text('Size: ${data.formattedSize}'),
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
                          case _MenuOption.save:
                            _onTapSaveBackup(context, file);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem<_MenuOption>(
                            value: _MenuOption.restore,
                            child: Text('Restore'),
                          ),
                          if (!kIsWeb)
                            PopupMenuItem<_MenuOption>(
                              value: _MenuOption.share,
                              child: Text('Share'),
                            ),
                          PopupMenuItem<_MenuOption>(
                            value: _MenuOption.delete,
                            child: Text('Delete'),
                          ),
                          PopupMenuItem<_MenuOption>(
                            value: _MenuOption.save,
                            child: Text('Save to File'),
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

  void _onTapDeleteBackup(BuildContext context, File file) async {
    final confirm = await onDeleteBackupConfirmation?.call();
    if (!context.mounted || confirm != true) return;
    await _cubit(context).deleteBackup(file);
    if (!context.mounted) return;
    context.showSnackBar(message: 'Success delete backup');
  }

  void _onTapShareBackup(BuildContext context, File file) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            await file.readAsBytes(),
            name: file.filename,
            mimeType: 'text/plain',
            path: file.path,
            length: await file.length(),
            lastModified: await file.lastModified(),
          ),
        ],
      ),
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

  void _onTapSaveBackup(BuildContext context, File file) async {
    final filename = '${file.filename}.${file.extension}';
    await fileSaverUseCase.execute(
      filename: filename,
      data: await file.readAsBytes(),
    );
    if (!context.mounted) return;
    context.showSnackBar(message: 'Success save backup to file');
  }

  void _onTapRestoreBackup(BuildContext context, File file) async {
    final confirm = await onRestoreBackupConfirmation?.call();
    if (!context.mounted || confirm != true) return;
    await _cubit(context).restoreBackup(file);
    if (!context.mounted) return;
    context.showSnackBar(message: 'Success restore backup');
    WrapperScreen.restart(context);
  }

  void _onTapAddBackupFromExternal(BuildContext context) async {
    final data = await filePickerUseCase.execute(allowedExtensions: ['sqlite']);
    if (!context.mounted || data == null) return;
    _cubit(context).addBackupFromData(data: data);
  }

  void _onTapBackupNow(BuildContext context) async {
    await _cubit(context).addBackupFromDatabase();
    if (!context.mounted) return;
    context.showSnackBar(message: 'Success adding backup');
  }
}

enum _MenuOption { share, restore, delete, save }

enum _AddBackupMenuOption { fromExternalFile, fromDatabase }
