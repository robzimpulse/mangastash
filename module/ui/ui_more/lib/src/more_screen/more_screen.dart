import 'package:core_environment/core_environment.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'more_screen_cubit.dart';
import 'more_screen_state.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback? onTapSetting;
  final VoidCallback? onTapStatistic;
  final VoidCallback? onTapDataStorage;
  final VoidCallback? onTapQueue;
  final VoidCallback? onTapAbout;
  final VoidCallback? onTapHelp;

  const MoreScreen({
    super.key,
    this.onTapSetting,
    this.onTapStatistic,
    this.onTapDataStorage,
    this.onTapQueue,
    this.onTapAbout,
    this.onTapHelp,
  });

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapSetting,
    VoidCallback? onTapStatistic,
    VoidCallback? onTapDataStorage,
    VoidCallback? onTapQueue,
    VoidCallback? onTapAbout,
    VoidCallback? onTapHelp,
  }) {
    return BlocProvider(
      create: (context) {
        return MoreScreenCubit(
          listenJobUseCase: locator(),
          listenSettingDownloadedOnlyUseCase: locator(),
          updateSettingDownloadedOnlyUseCase: locator(),
          listenSettingIncognitoUseCase: locator(),
          updateSettingIncognitoUseCase: locator(),
        );
      },
      child: MoreScreen(
        onTapSetting: onTapSetting,
        onTapStatistic: onTapStatistic,
        onTapDataStorage: onTapDataStorage,
        onTapQueue: onTapQueue,
        onTapAbout: onTapAbout,
      ),
    );
  }

  BlocBuilder _builder({
    required BlocWidgetBuilder<MoreScreenState> builder,
    BlocBuilderCondition<MoreScreenState>? buildWhen,
  }) {
    return BlocBuilder<MoreScreenCubit, MoreScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  MoreScreenCubit _cubit(BuildContext context) => context.read();

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Manga Stash',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      return Text(
                        [
                          snapshot.data?.version,
                          '(${snapshot.data?.buildNumber})',
                        ].join(' '),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: AdaptivePhysicListView(
              padding: EdgeInsets.zero,
              children: [
                _builder(
                  buildWhen: (prev, curr) {
                    return prev.isDownloadedOnly != curr.isDownloadedOnly;
                  },
                  builder: (context, state) {
                    return SwitchListTile(
                      title: const Text('Downloaded Only'),
                      subtitle: const Text(
                        'Filters all entries in your library',
                      ),
                      value: state.isDownloadedOnly,
                      onChanged: (_) {
                        _cubit(context).toggleIsDownloadedOnly();
                      },
                      secondary: const SizedBox(
                        height: double.infinity,
                        child: Icon(Icons.cloud_off),
                      ),
                    );
                  },
                ),
                _builder(
                  buildWhen: (prev, curr) {
                    return prev.isIncognito != curr.isIncognito;
                  },
                  builder: (context, state) {
                    return SwitchListTile(
                      title: const Text('Incognito Mode'),
                      subtitle: const Text('Pause reading history'),
                      value: state.isIncognito,
                      onChanged: (_) => _cubit(context).toggleIsIncognito(),
                      secondary: const SizedBox(
                        height: double.infinity,
                        child: Icon(Icons.disabled_visible),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 1),
                _builder(
                  buildWhen: (prev, curr) => prev.jobCount != curr.jobCount,
                  builder: (context, state) {
                    return ListTile(
                      title: const Text('Job Queue'),
                      subtitle: Text('${state.jobCount} remaining'),
                      onTap: onTapQueue,
                      leading: const SizedBox(
                        height: double.infinity,
                        child: Icon(Icons.download),
                      ),
                    );
                  },
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
                  title: const Text('Data and Storage'),
                  onTap: onTapDataStorage,
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.storage),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
