import 'package:data_manga/data_manga.dart';
import 'package:equatable/equatable.dart';

import 'state/manga_section_state.dart';
import 'state/tags_section_state.dart';

class SearchScreenCubitState extends Equatable {

  final MangaSectionState mangaSectionState;

  final TagsSectionState tagsSectionState;

  const SearchScreenCubitState({
    this.mangaSectionState = const MangaSectionState(),
    this.tagsSectionState = const TagsSectionState(),
  });

  @override
  List<Object?> get props => [mangaSectionState, tagsSectionState];

  SearchScreenCubitState copyWith({
    MangaSectionState? mangaSectionState,
    TagsSectionState? tagsSectionState,
  }) {
    return SearchScreenCubitState(
      mangaSectionState: mangaSectionState ?? this.mangaSectionState,
      tagsSectionState: tagsSectionState ?? this.tagsSectionState,
    );
  }
}