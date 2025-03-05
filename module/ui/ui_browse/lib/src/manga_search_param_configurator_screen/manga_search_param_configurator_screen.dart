import 'package:core_environment/core_environment.dart';
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
        ...[
          _status(),
          _contentRating(),
          _includes(),
          _originalLanguage(),
          _availableTranslatedLanguage(),
          _publicationDemographic(),
        ].map((e) => SliverToBoxAdapter(child: e)),
      ],
    );
  }

  Widget _status() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.modified?.status != curr.modified?.status,
      ].contains(true),
      builder: (context, state) => ExpansionTile(
        title: const Text('Status'),
        children: [
          ...MangaStatus.values.map(
            (key) => CheckboxListTile(
              title: Text(key.label),
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
    );
  }

  Widget _contentRating() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.modified?.contentRating != curr.modified?.contentRating,
      ].contains(true),
      builder: (context, state) => ExpansionTile(
        title: const Text('Content Rating'),
        children: [
          ...ContentRating.values.map(
            (key) => CheckboxListTile(
              title: Text(key.label),
              value: state.modified?.contentRating?.contains(key) == true,
              onChanged: (value) {
                if (value == null) return;
                final values = [...?state.modified?.contentRating];
                if (value) {
                  values.add(key);
                } else {
                  values.remove(key);
                }
                _cubit(context).update(
                  modified: state.modified?.copyWith(
                    contentRating: values,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _includes() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.modified?.includes != curr.modified?.includes,
      ].contains(true),
      builder: (context, state) => ExpansionTile(
        title: const Text('Includes'),
        children: [
          ...Include.values.map(
            (key) => CheckboxListTile(
              title: Text(key.label),
              value: state.modified?.includes?.contains(key) == true,
              onChanged: (value) {
                if (value == null) return;
                final values = [...?state.modified?.includes];
                if (value) {
                  values.add(key);
                } else {
                  values.remove(key);
                }
                _cubit(context).update(
                  modified: state.modified?.copyWith(
                    includes: values,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _originalLanguage() {
    return _builder(
      buildWhen: (prev, curr) {
        final a = prev.modified;
        final b = curr.modified;

        return [
          a?.originalLanguage != b?.originalLanguage,
          a?.excludedOriginalLanguages != b?.excludedOriginalLanguages,
        ].contains(true);
      },
      builder: (context, state) => ExpansionTile(
        title: const Text('Original Language'),
        children: [
          ...LanguageCodes.values.map(
            (key) {
              final data = state.modified;
              final included = data?.originalLanguage;
              final excluded = data?.excludedOriginalLanguages;

              return CheckboxListTile(
                title: Text(key.label),
                tristate: true,
                value: (included?.contains(key) ?? false)
                    ? true
                    : (excluded?.contains(key) ?? false)
                        ? null
                        : false,
                onChanged: (value) {
                  final originalLanguage = (value == true)
                      ? ([...?included, key])
                      : ([...?included]..remove(key));

                  final excludedOriginalLanguages = (value == null)
                      ? ([...?excluded, key])
                      : ([...?excluded]..remove(key));

                  _cubit(context).update(
                    modified: data?.copyWith(
                        originalLanguage: originalLanguage,
                        excludedOriginalLanguages: excludedOriginalLanguages),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _availableTranslatedLanguage() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.modified?.availableTranslatedLanguage !=
            curr.modified?.availableTranslatedLanguage,
      ].contains(true),
      builder: (context, state) => ExpansionTile(
        title: const Text('Available Translated Language'),
        children: [
          ...LanguageCodes.values.map(
            (key) => CheckboxListTile(
              title: Text(key.label),
              value:
                  state.modified?.availableTranslatedLanguage?.contains(key) ==
                      true,
              onChanged: (value) {
                if (value == null) return;
                final values = [
                  ...?state.modified?.availableTranslatedLanguage
                ];
                if (value) {
                  values.add(key);
                } else {
                  values.remove(key);
                }
                _cubit(context).update(
                  modified: state.modified?.copyWith(
                    availableTranslatedLanguage: values,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _publicationDemographic() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.modified?.publicationDemographic !=
            curr.modified?.publicationDemographic,
      ].contains(true),
      builder: (context, state) => ExpansionTile(
        title: const Text('Publication Demographic'),
        children: [
          ...PublicDemographic.values.map(
            (key) => CheckboxListTile(
              title: Text(key.label),
              value:
                  state.modified?.publicationDemographic?.contains(key) == true,
              onChanged: (value) {
                if (value == null) return;
                final values = [...?state.modified?.publicationDemographic];
                if (value) {
                  values.add(key);
                } else {
                  values.remove(key);
                }
                _cubit(context).update(
                  modified: state.modified?.copyWith(
                    publicationDemographic: values,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
