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
        initialState: const AppearanceScreenState(),
        updateThemeUseCase: locator(),
        listenThemeUseCase: locator(),
      ),
      child: const AppearanceScreen(),
    );
  }

  AppearanceScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<AppearanceScreenState> builder,
    BlocBuilderCondition<AppearanceScreenState>? buildWhen,
  }) {
    return BlocBuilder<AppearanceScreenCubit, AppearanceScreenState>(
      buildWhen: buildWhen,
      builder: builder,
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
      ),
    );
  }
}
