import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

import 'state/manga_section_state.dart';
import 'state/tags_section_state.dart';

class SearchScreenCubitState extends Equatable {

  final MangaSectionState mangaSectionState;

  final TagsSectionState tagsSectionState;

  final SearchMangaParameter parameter;

  const SearchScreenCubitState({
    this.mangaSectionState = const MangaSectionState(),
    this.tagsSectionState = const TagsSectionState(),
    this.parameter = const SearchMangaParameter(),
  });

  @override
  List<Object?> get props => [mangaSectionState, tagsSectionState, parameter];

  SearchScreenCubitState copyWith({
    MangaSectionState? mangaSectionState,
    TagsSectionState? tagsSectionState,
    SearchMangaParameter? parameter,
  }) {
    return SearchScreenCubitState(
      mangaSectionState: mangaSectionState ?? this.mangaSectionState,
      tagsSectionState: tagsSectionState ?? this.tagsSectionState,
      parameter: parameter ?? this.parameter,
    );
  }

  bool get canFetchNextPage {
    return !mangaSectionState.isPaging || mangaSectionState.hasNextPage;
  }
}