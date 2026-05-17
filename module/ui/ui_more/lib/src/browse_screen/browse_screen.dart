import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_screen_cubit.dart';
import 'browse_screen_state.dart';

class BrowseScreen extends StatelessWidget {
  final VoidCallback? onTapManageDynamicSource;

  const BrowseScreen({
    super.key,
    this.onTapManageDynamicSource,
  });

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapManageDynamicSource,
  }) {
    return BlocProvider(
      create: (context) => BrowseScreenCubit(
        updateSearchParameterUseCase: locator(),
        listenSearchParameterUseCase: locator(),
        updateSourcesUseCase: locator(),
        listenSourcesUseCase: locator(),
        sourceManager: locator(),
      ),
      child: BrowseScreen(onTapManageDynamicSource: onTapManageDynamicSource),
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
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.sources != curr.sources,
          prev.allSources != curr.allSources,
        ].contains(true);
      },
      builder: (context, state) => ExpansionTile(
        title: const Text('Source Options'),
        subtitle: const Text('Available Sources for Manga'),
        leading: const Icon(Icons.source),
        children: [
          ...state.allSources.map(
            (source) => CheckboxListTile(
              title: Text(source.name),
              value: state.sources.map((e) => e.name).contains(source.name),
              onChanged: (value) {
                if (value == null) return;
                final values = [...state.sources];
                if (value) {
                  values.add(source);
                } else {
                  values.removeWhere((e) => e.name == source.name);
                }
                _cubit(context)?.update(sources: values);
              },
            ),
          ),
        ],
      ),
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
          ListTile(
            title: const Text('Manage Dynamic Sources'),
            subtitle: const Text('Add or remove custom sources'),
            leading: const Icon(Icons.settings_applications),
            onTap: onTapManageDynamicSource,
          ),
        ],
      ),
    );
  }
}
