import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
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
        initialState: const MangaSearchParamConfiguratorScreenState(),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Reset')),
              OutlinedButton(onPressed: () {}, child: const Text('Filter')),
            ],
          ),
        ),
        ListView(
          controller: scrollController,
          shrinkWrap: true,
          children: [
            _builder(
              buildWhen: (prev, curr) => [
                prev.hasAvailableChapters != curr.hasAvailableChapters,
              ].any((e) => e),
              builder: (context, state) => CheckboxListTile(
                title: const Text('Has Available Chapter'),
                value: state.hasAvailableChapters,
                onChanged: (value) => _cubit(context).update(
                  hasAvailableChapters: value,
                ),
              ),
            ),
            _builder(
              buildWhen: (prev, curr) => [
                prev.originalLanguage != curr.originalLanguage,
              ].any((e) => e),
              builder: (context, state) => ExpansionTile(
                title: const Text('Original Language'),
                children: [
                  for (final key in LanguageCodes.values)
                    CheckboxListTile(
                      title: Text(key.rawValue),
                      value: state.originalLanguage[key],
                      tristate: true,
                      onChanged: (value) => _cubit(context).update(
                        originalLanguage: Map.of(state.originalLanguage)
                          ..update(
                            key,
                            (_) => value,
                            ifAbsent: () => value,
                          ),
                      ),
                    ),
                ],
              ),
            ),
            _builder(
              buildWhen: (prev, curr) => [
                prev.contentRating != curr.contentRating,
              ].any((e) => e),
              builder: (context, state) => ExpansionTile(
                title: const Text('Content Rating'),
                children: [
                  for (final key in ContentRating.values)
                    CheckboxListTile(
                      title: Text(key.rawValue),
                      value: state.contentRating.contains(key),
                      onChanged: (value) {
                        if (value == null) return;
                        final contentRating = List.of(state.contentRating);
                        if (value) {
                          contentRating.add(key);
                        } else {
                          contentRating.remove(key);
                        }
                        _cubit(context).update(contentRating: contentRating);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
