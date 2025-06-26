import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'backup_restore_screen_cubit.dart';
import 'backup_restore_screen_state.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => BackupRestoreScreenCubit()..init(),
      child: const BackupRestoreScreen(),
    );
  }

  BackupRestoreScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<BackupRestoreScreenState> builder,
    BlocBuilderCondition<BackupRestoreScreenState>? buildWhen,
  }) {
    return BlocBuilder<BackupRestoreScreenCubit, BackupRestoreScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Backup and Restore'),
      ),
      body: const CustomScrollView(
        slivers: [
          // TODO: @robzimpulse - broken on web
          // _builder(
          //   builder: (context, state) => SliverToBoxAdapter(
          //     child: ListTile(
          //       title: const Text('Backup Location'),
          //       subtitle: Text(
          //         state.backupPath?.path ?? 'Unsupported Platform',
          //       ),
          //       onTap: () async {
          //         final path = await FilesystemPicker.open(
          //           title: 'Save to folder',
          //           context: context,
          //           rootDirectory: state.rootPath,
          //           directory: state.backupPath,
          //           fsType: FilesystemType.folder,
          //           pickText: 'Save file to this folder',
          //           contextActions: [
          //             FilesystemPickerNewFolderContextAction(),
          //           ],
          //           requestPermission: () async {
          //             await [
          //               Permission.manageExternalStorage,
          //               Permission.storage,
          //             ].request();
          //
          //             final isGranted = await Future.wait([
          //               Permission.manageExternalStorage.isGranted,
          //               Permission.storage.isGranted,
          //             ]);
          //
          //             return isGranted.any((e) => e);
          //           },
          //         );
          //
          //         if (!context.mounted || path == null) return;
          //
          //         _cubit(context).setBackupPath(path);
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
