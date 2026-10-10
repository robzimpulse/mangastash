// BrowseScreen: the "Browse" settings page — the global search-manga filter
// and a "Sources" entry. The entry calls [BrowseScreen.onTapSources]; the
// per-source enable checkboxes moved to the source list screen it opens
// (issue #115). Until a route is wired the tile is disabled.
//
// Usage: `BrowseScreen.create(locator: locator, onTapSources: () => ...)`.
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_screen_cubit.dart';
import 'browse_screen_state.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({
    super.key,
    this.onTapSources,
  });

  /// Opens the list of sources; null disables the "Sources" tile.
  final VoidCallback? onTapSources;

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapSources,
  }) {
    return BlocProvider(
      create: (context) => BrowseScreenCubit(
        updateSearchParameterUseCase: locator(),
        listenSearchParameterUseCase: locator(),
        updateSourcesUseCase: locator(),
        listenSourcesUseCase: locator(),
      ),
      child: BrowseScreen(onTapSources: onTapSources),
    );
  }

  BrowseScreenCubit? _cubit(BuildContext context) {
    return context.mounted ? context.read() : null;
  }

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
            onChanged: (parameter) => _cubit(context)?.update(
              parameter: parameter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceOption({required BuildContext context}) {
    return ListTile(
      title: const Text('Sources'),
      subtitle: const Text('Enable, edit and add manga sources'),
      leading: const Icon(Icons.source),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTapSources,
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
          _buildSourceOption(context: context),
        ],
      ),
    );
  }
}
