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
          backupDatabaseUseCase: locator(),
          setBackupPathUseCase: locator(),
          listenBackupPathUseCase: locator(),
          restoreDatabaseUseCase: locator(),
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
                    onTap: () async {
                      final e = await _cubit(context).setBackupPath(context);
                      if (!context.mounted) return;

                      context.showSnackBar(
                        message: e != null ? '$e' : 'Success set backup path',
                      );
                    },
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final e = await _cubit(context).backup(context);
                      if (!context.mounted) return;
                      context.showSnackBar(
                        message: e != null ? '$e' : 'Success backup database',
                      );
                    },
                    child: Text('Backup'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final e = await _cubit(context).restore(context);
                      if (!context.mounted) return;
                      context.showSnackBar(
                        message: e != null ? '$e' : 'Success restore database',
                      );
                    },
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
}
