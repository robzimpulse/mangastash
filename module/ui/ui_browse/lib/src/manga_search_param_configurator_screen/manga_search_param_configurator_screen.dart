import 'package:core_route/core_route.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_search_param_configurator_screen_cubit.dart';
import 'manga_search_param_configurator_screen_state.dart';

class MangaSearchParamConfiguratorScreen extends StatelessWidget {
  const MangaSearchParamConfiguratorScreen({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  static Widget create({
    required ServiceLocator locator,
    SearchMangaParameter? param,
    ScrollController? scrollController,
  }) {
    return BlocProvider(
      create: (context) => MangaSearchParamConfiguratorScreenCubit(
        initialState: MangaSearchParamConfiguratorScreenState(
          original: param,
          modified: param,
        ),
      ),
      child: MangaSearchParamConfiguratorScreen(
        scrollController: scrollController,
      ),
    );
  }

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaSearchParamConfiguratorScreenState> builder,
    BlocBuilderCondition<MangaSearchParamConfiguratorScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaSearchParamConfiguratorScreenCubit,
        MangaSearchParamConfiguratorScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  MangaSearchParamConfiguratorScreenCubit _cubit(BuildContext context) =>
      context.read();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPinnedHeader(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => _cubit(context).reset,
                  child: const Text('Reset'),
                ),
                _builder(
                  buildWhen: (prev, curr) => prev.modified != curr.modified,
                  builder: (context, state) => OutlinedButton(
                    onPressed: () => context.pop(state.modified),
                    child: const Text('Filter'),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _builder(
            builder: (context, state) => MangaParameterWidget(
              parameter: state.modified ?? const SearchMangaParameter(),
              onChanged: (parameter) => _cubit(context).update(
                modified: parameter,
              ),
              // TODO: add available tags for specific source
              availableTags: const {},
            ),
          ),
        ),
      ],
    );
  }
}
