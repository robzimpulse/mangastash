import 'package:filesystem_picker/filesystem_picker.dart';
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
      create: (context) => BackupRestoreScreenCubit(
        listenDownloadPathUseCase: locator(),
        getRootPathUseCase: locator(),
        setDownloadPathUseCase: locator(),
      ),
      child: const BackupRestoreScreen(),
    );
  }

  BackupRestoreScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
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
      body: CustomScrollView(
        slivers: [
          _builder(
            builder: (context, state) => SliverToBoxAdapter(
              child: ListTile(
                title: const Text('Backup Location'),
                subtitle: Text(
                  state.downloadPath?.path ?? 'Unsupported Platform',
                ),
                onTap: () async {
                  final path = await FilesystemPicker.open(
                    title: 'Save to folder',
                    context: context,
                    rootDirectory: state.rootPath,
                    directory: state.downloadPath,
                    fsType: FilesystemType.folder,
                    pickText: 'Save file to this folder',
                    contextActions: [
                      FilesystemPickerNewFolderContextAction(),
                    ],
                  );

                  if (!context.mounted || path == null) return;

                  _cubit(context).setDownloadPath(path);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
