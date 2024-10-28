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
        getRootPathUseCase: locator(),
      ),
      child: const BackupRestoreScreen(),
    );
  }

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
                subtitle: Text(state.path ?? 'Unsupported Platform'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
