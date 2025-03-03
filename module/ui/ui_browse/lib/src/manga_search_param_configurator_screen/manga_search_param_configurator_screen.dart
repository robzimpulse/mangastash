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
            buildWhen: (prev, curr) => [
              prev.modified?.status != curr.modified?.status,
            ].contains(true),
            builder: (context, state) => ExpansionTile(
              title: const Text('Status'),
              children: [
                ...MangaStatus.values.map(
                  (key) => CheckboxListTile(
                    title: Text(key.rawValue.toCapitalized()),
                    value: state.modified?.status?.contains(key) == true,
                    onChanged: (value) {
                      if (value == null) return;
                      final values = [...?state.modified?.status];
                      if (value) {
                        values.add(key);
                      } else {
                        values.remove(key);
                      }
                      _cubit(context).update(
                        modified: state.modified?.copyWith(status: values),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // SliverToBoxAdapter(
        //   child: _builder(
        //     buildWhen: (prev, curr) => [
        //       prev.modified != curr.hasAvailableChapters,
        //     ].contains(true),
        //     builder: (context, state) => CheckboxListTile(
        //       title: const Text('Has Available Chapter'),
        //       value: state.hasAvailableChapters,
        //       onChanged: (value) => _cubit(context).update(
        //         hasAvailableChapters: value,
        //       ),
        //     ),
        //   ),
        // ),
        // SliverToBoxAdapter(
        //   child: _builder(
        //     buildWhen: (prev, curr) => [
        //       prev.originalLanguage != curr.originalLanguage,
        //     ].contains(true),
        //     builder: (context, state) => ExpansionTile(
        //       title: const Text('Original Language'),
        //       children: [
        //         for (final key in LanguageCodes.values)
        //           CheckboxListTile(
        //             title: Text(key.rawValue),
        //             value: state.originalLanguage[key],
        //             tristate: true,
        //             onChanged: (value) => _cubit(context).update(
        //               originalLanguage: Map.of(state.originalLanguage)
        //                 ..update(
        //                   key,
        //                   (_) => value,
        //                   ifAbsent: () => value,
        //                 ),
        //             ),
        //           ),
        //       ],
        //     ),
        //   ),
        // ),
        // SliverToBoxAdapter(
        //   child: _builder(
        //     buildWhen: (prev, curr) => [
        //       prev.contentRating != curr.contentRating,
        //     ].contains(true),
        //     builder: (context, state) => ExpansionTile(
        //       title: const Text('Content Rating'),
        //       children: [
        //         for (final key in ContentRating.values)
        //           CheckboxListTile(
        //             title: Text(key.rawValue),
        //             value: state.contentRating.contains(key),
        //             onChanged: (value) {
        //               if (value == null) return;
        //               final contentRating = List.of(state.contentRating);
        //               if (value) {
        //                 contentRating.add(key);
        //               } else {
        //                 contentRating.remove(key);
        //               }
        //               _cubit(context).update(contentRating: contentRating);
        //             },
        //           ),
        //       ],
        //     ),
        //   ),
        // ),
        // TODO: add more parameter
      ],
    );
  }
}
