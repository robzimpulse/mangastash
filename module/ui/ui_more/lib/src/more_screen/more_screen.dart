import 'package:core_auth/core_auth.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'more_screen_cubit.dart';
import 'more_screen_state.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback? onTapSetting;
  final VoidCallback? onTapStatistic;
  final VoidCallback? onTapBackupRestore;
  final VoidCallback? onTapDownloadQueue;
  final VoidCallback? onTapAbout;
  final VoidCallback? onTapHelp;
  final VoidCallback? onTapLogin;

  const MoreScreen({
    super.key,
    this.onTapSetting,
    this.onTapStatistic,
    this.onTapBackupRestore,
    this.onTapDownloadQueue,
    this.onTapAbout,
    this.onTapHelp,
    this.onTapLogin,
  });

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapSetting,
    VoidCallback? onTapStatistic,
    VoidCallback? onTapBackupRestore,
    VoidCallback? onTapDownloadQueue,
    VoidCallback? onTapAbout,
    VoidCallback? onTapHelp,
    VoidCallback? onTapLogin,
  }) {
    return BlocProvider(
      create: (context) => MoreScreenCubit(
        listenAuthUseCase: locator(),
        logoutUseCase: locator(),
        listenActiveDownloadUseCase: locator(),
      ),
      child: MoreScreen(
        onTapSetting: onTapSetting,
        onTapStatistic: onTapStatistic,
        onTapBackupRestore: onTapBackupRestore,
        onTapDownloadQueue: onTapDownloadQueue,
        onTapAbout: onTapAbout,
        onTapLogin: onTapLogin,
      ),
    );
  }

  MoreScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<MoreScreenState> builder,
    BlocBuilderCondition<MoreScreenState>? buildWhen,
  }) {
    return BlocBuilder<MoreScreenCubit, MoreScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      body: Column(
        children: [
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Manga Stash',
                style: TextStyle(fontSize: 56),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: AdaptivePhysicListView(
              padding: EdgeInsets.zero,
              children: [
                SwitchListTile(
                  title: const Text('Downloaded Only'),
                  subtitle: const Text('Filters all entries in your library'),
                  value: true,
                  // TODO: implement this
                  onChanged: (value) => context.showSnackBar(
                    message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
                  ),
                  secondary: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.cloud_off),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Incognito Mode'),
                  subtitle: const Text('Pause reading history'),
                  value: true,
                  // TODO: implement this
                  onChanged: (value) => context.showSnackBar(
                    message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
                  ),
                  secondary: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.disabled_visible),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                _builder(
                  buildWhen: (prev, curr) {
                    return prev.totalActiveDownload != curr.totalActiveDownload;
                  },
                  builder: (context, state) => ListTile(
                    title: const Text('Download Queue'),
                    subtitle: Text('${state.totalActiveDownload} remaining'),
                    onTap: onTapDownloadQueue,
                    leading: const SizedBox(
                      height: double.infinity,
                      child: Icon(Icons.download),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Statistic'),
                  onTap: onTapStatistic,
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.auto_graph),
                  ),
                ),
                ListTile(
                  title: const Text('Backup and Restore'),
                  onTap: onTapBackupRestore,
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.settings_backup_restore),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                ListTile(
                  title: const Text('Settings'),
                  onTap: onTapSetting,
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.settings),
                  ),
                ),
                ListTile(
                  title: const Text('About'),
                  onTap: onTapAbout,
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.info_outline),
                  ),
                ),
                ListTile(
                  title: const Text('Help'),
                  onTap: onTapHelp,
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.help_outline),
                  ),
                ),
                _builder(
                  buildWhen: (prev, curr) {
                    return prev.authState != curr.authState;
                  },
                  builder: (context, state) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: state.authState?.status == AuthStatus.loggedOut
                          ? onTapLogin
                          : () => _cubit(context).logout(),
                      child: Text(
                        state.authState?.status == AuthStatus.loggedOut
                            ? 'Login'
                            : 'Logout',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
