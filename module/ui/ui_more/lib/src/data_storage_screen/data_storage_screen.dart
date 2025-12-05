import 'package:flutter/foundation.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'data_storage_screen_cubit.dart';
import 'data_storage_screen_state.dart';

class DataStorageScreen extends StatelessWidget {
  const DataStorageScreen({super.key});

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (context) {
        return DataStorageScreenCubit(
          database: locator(),
          setBackupPathUseCase: locator(),
          listenBackupPathUseCase: locator(),
          filesystemPickerUsecase: locator(),
        );
      },
      child: const DataStorageScreen(),
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
      body: CustomScrollView(
        slivers: [
          if (kIsWeb) ...[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('This feature were unsupported on Web'),
              ),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: _builder(
                builder: (context, state) {
                  return ListTile(
                    title: const Text('Backup Location'),
                    subtitle: Text(state.backupPath?.path ?? '-'),
                    onTap: () => _onTapSetBackupPath(context),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _onTapBackup(context),
                    child: Text('Backup'),
                  ),
                  ElevatedButton(
                    onPressed: () => _onTapRestore(context),
                    child: Text('Restore'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onTapRestore(BuildContext context) async {
    try {
      await _cubit(context).restore(context);
      if (!context.mounted) return;
      context.showSnackBar(message: 'Success restore database');
    } catch (e) {
      if (!context.mounted) return;
      context.showSnackBar(message: e.toString());
    }
  }

  void _onTapBackup(BuildContext context) async {
    try {
      final file = await _cubit(context).backup();
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
      await file.delete();
      if (!context.mounted) return;

      switch (result.status) {
        case ShareResultStatus.success:
          context.showSnackBar(message: 'Success backup database');
        case ShareResultStatus.dismissed:
          context.showSnackBar(message: 'Cancel backup database');
        case ShareResultStatus.unavailable:
          context.showSnackBar(message: 'Failed backup database');
      }
    } catch (e) {
      if (!context.mounted) return;
      context.showSnackBar(message: e.toString());
    }
  }

  void _onTapSetBackupPath(BuildContext context) async {
    try {
      await _cubit(context).setBackupPath(context);
      if (!context.mounted) return;
      context.showSnackBar(message: 'Success set backup path');
    } catch (e) {
      if (!context.mounted) return;
      context.showSnackBar(message: e.toString());
    }
  }
}
