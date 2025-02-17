import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_search_param_configurator_screen_state.dart';

class MangaSearchParamConfiguratorScreenCubit
    extends Cubit<MangaSearchParamConfiguratorScreenState> {
  MangaSearchParamConfiguratorScreenCubit({
    MangaSearchParamConfiguratorScreenState initialState =
        const MangaSearchParamConfiguratorScreenState(),
  }) : super(initialState);

  void update({
    bool? hasAvailableChapters,
    Map<LanguageCodes, bool?>? originalLanguage,
    List<ContentRating>? contentRating,
    List<PublicDemographic>? publicationDemographic,
    List<MangaStatus>? status,
    SearchOrders? orderBy,
    OrderDirections? orderDirection,
    List<String>? includedTags,
    TagsMode? includedTagsMode,
    List<String>? excludedTags,
    TagsMode? excludedTagsMode,
  }) {
    emit(
      state.copyWith(
        hasAvailableChapters: hasAvailableChapters,
        originalLanguage: originalLanguage,
        contentRating: contentRating,
        publicationDemographic: publicationDemographic,
        status: status,
        orderBy: orderBy,
        orderDirection: orderDirection,
        includedTags: includedTags,
        includedTagsMode: includedTagsMode,
        excludedTags: excludedTags,
        excludedTagsMode: excludedTagsMode,
      ),
    );
  }
}
