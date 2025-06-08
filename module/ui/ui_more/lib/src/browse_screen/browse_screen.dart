import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_screen_cubit.dart';
import 'browse_screen_state.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => BrowseScreenCubit(
        initialState: const BrowseScreenState(),
        updateSearchParameterUseCase: locator(),
        listenSearchParameterUseCase: locator(),
      ),
      child: const BrowseScreen(),
    );
  }

  BrowseScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<BrowseScreenState> builder,
    BlocBuilderCondition<BrowseScreenState>? buildWhen,
  }) {
    return BlocBuilder<BrowseScreenCubit, BrowseScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _buildSearchMangaOption({required BuildContext context}) {
    return ExpansionTile(
      title: const Text('Search Manga Options'),
      subtitle: const Text('Global Filter for Browsing Manga'),
      leading: const Icon(Icons.filter_list),
      children: [
        _builder(
          buildWhen: (prev, curr) => prev.parameter != curr.parameter,
          builder: (context, state) => MangaParameterWidget(
            parameter: state.parameter,
            onChanged: (parameter) => _cubit(context).update(
              parameter: parameter,
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
        title: const Text('Browse Screen'),
      ),
      body: AdaptivePhysicListView(
        children: [
          _buildSearchMangaOption(context: context),
        ],
      ),
    );
  }
}
