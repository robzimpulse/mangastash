import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'download_screen_cubit.dart';
import 'download_screen_state.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => DownloadScreenCubit()..init(),
      child: const DownloadScreen(),
    );
  }

  DownloadScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<DownloadScreenState> builder,
    BlocBuilderCondition<DownloadScreenState>? buildWhen,
  }) {
    return BlocBuilder<DownloadScreenCubit, DownloadScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Download Screen'),
      ),
      body: const CustomScrollView(
        slivers: [
          // TODO: @robzimpulse - broken on web
          // _builder(
          //   builder: (context, state) => SliverToBoxAdapter(
          //     child: ListTile(
          //       title: const Text('Download Location'),
          //       subtitle: Text(
          //         state.downloadPath?.path ?? 'Unsupported Platform',
          //       ),
          //       onTap: () async {
          //         final path = await FilesystemPicker.open(
          //           title: 'Save to folder',
          //           context: context,
          //           rootDirectory: state.rootPath,
          //           directory: state.downloadPath,
          //           fsType: FilesystemType.folder,
          //           pickText: 'Save file to this folder',
          //           contextActions: [
          //             FilesystemPickerNewFolderContextAction(),
          //           ],
          //         );
          //
          //         if (!context.mounted || path == null) return;
          //
          //         _cubit(context).setDownloadPath(path);
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
