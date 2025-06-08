import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
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
          buildWhen: (prev, curr) => [
            prev.parameter.status != curr.parameter.status,
          ].contains(true),
          builder: (context, state) => ExpansionTile(
            title: const Text('Status'),
            children: [
              ...MangaStatus.values.map(
                (key) => CheckboxListTile(
                  title: Text(key.label),
                  value: state.parameter.status?.contains(key) == true,
                  onChanged: (value) {
                    if (value == null) return;
                    final values = [...?state.parameter.status];
                    value ? values.add(key) : values.remove(key);
                    _cubit(context).update(
                      modified: state.parameter.copyWith(status: values),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => [
            prev.parameter.contentRating != curr.parameter.contentRating,
          ].contains(true),
          builder: (context, state) => ExpansionTile(
            title: const Text('Content Rating'),
            children: [
              ...ContentRating.values.map(
                (key) => CheckboxListTile(
                  title: Text(key.label),
                  value: state.parameter.contentRating?.contains(key) == true,
                  onChanged: (value) {
                    if (value == null) return;
                    final values = [...?state.parameter.contentRating];
                    value ? values.add(key) : values.remove(key);
                    _cubit(context).update(
                      modified: state.parameter.copyWith(
                        contentRating: values,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        _builder(
          buildWhen: (prev, curr) {
            final old = prev.parameter;
            final newest = curr.parameter;
            return [
              old.originalLanguage != newest.originalLanguage,
              old.excludedOriginalLanguages != newest.excludedOriginalLanguages,
            ].contains(true);
          },
          builder: (context, state) => ExpansionTile(
            title: const Text('Original Language'),
            children: [
              ...LanguageCodes.values.map(
                (key) {
                  final data = state.parameter;
                  final included = data.originalLanguage;
                  final excluded = data.excludedOriginalLanguages;

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
                        modified: data.copyWith(
                          originalLanguage: originalLanguage,
                          excludedOriginalLanguages: excludedOriginalLanguages,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        _builder(
          buildWhen: (prev, curr) {
            final old = prev.parameter.availableTranslatedLanguage;
            final current = curr.parameter.availableTranslatedLanguage;
            return old != current;
          },
          builder: (context, state) {
            final param = state.parameter.availableTranslatedLanguage;
            return ExpansionTile(
              title: const Text('Available Translated Language'),
              children: [
                ...LanguageCodes.values.map(
                  (key) => CheckboxListTile(
                    title: Text(key.label),
                    value: param?.contains(key) == true,
                    onChanged: (value) {
                      if (value == null) return;
                      final values = [...?param];
                      value ? values.add(key) : values.remove(key);
                      _cubit(context).update(
                        modified: state.parameter.copyWith(
                          availableTranslatedLanguage: values,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        _builder(
          buildWhen: (prev, curr) {
            final old = prev.parameter.publicationDemographic;
            final current = curr.parameter.publicationDemographic;
            return old != current;
          },
          builder: (context, state) {
            final param = state.parameter.publicationDemographic;
            return ExpansionTile(
              title: const Text('Publication Demographic'),
              children: [
                ...PublicDemographic.values.map(
                  (key) => CheckboxListTile(
                    title: Text(key.label),
                    value: param?.contains(key) == true,
                    onChanged: (value) {
                      if (value == null) return;
                      final values = [...?param];
                      value ? values.add(key) : values.remove(key);
                      _cubit(context).update(
                        modified: state.parameter.copyWith(
                          publicationDemographic: values,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
