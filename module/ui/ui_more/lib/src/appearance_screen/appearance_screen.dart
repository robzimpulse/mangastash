import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'appearance_screen_cubit.dart';
import 'appearance_screen_state.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (_) => AppearanceScreenCubit(
        updateThemeUseCase: locator(),
        listenThemeUseCase: locator(),
      ),
      child: const AppearanceScreen(),
    );
  }

  AppearanceScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<AppearanceScreenState> builder,
    BlocBuilderCondition<AppearanceScreenState>? buildWhen,
  }) {
    return BlocBuilder<AppearanceScreenCubit, AppearanceScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _buildThemeMenu(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Text(
              'Theme',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _builder(
            buildWhen: (prev, curr) => prev.isDarkMode != curr.isDarkMode,
            builder: (_, state) => SwitchListTile(
              title: Text('${state.isDarkMode ? 'Lights' : 'Dark'} Mode'),
              value: state.isDarkMode,
              onChanged: (value) => _cubit(context).changeDarkMode(value),
              secondary: SizedBox(
                height: double.infinity,
                child: Icon(
                  state.isDarkMode
                      ? Icons.lightbulb_outline
                      : Icons.lightbulb_sharp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampMenu(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Text(
              'Timestamp Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: const Text('Relative timestamps'),
            trailing: const Text('Short (Today, Yesterday)'),
            // TODO: implement this
            onTap: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: const Text('Date format'),
            trailing: const Text('Default (MM/dd/yy)'),
            // TODO: implement this
            onTap: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayMenu(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Text(
              'Display',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: const Text('Tablet UI'),
            trailing: const Text('Automatic'),
            // TODO: implement this
            onTap: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Appearance Screen'),
      ),
      body: CustomScrollView(
        slivers: [
          _buildThemeMenu(context),
          _buildDisplayMenu(context),
          _buildTimestampMenu(context),
        ],
      ),
    );
  }
}
