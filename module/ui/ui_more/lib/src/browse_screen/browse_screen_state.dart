// BrowseScreenState: the global search-manga parameter edited on the Browse
// settings screen. Enabled sources are managed on the source list screen
// (issue #115), so they are no longer part of this state.
//
// Usage: `state.copyWith(parameter: p)`.
import 'package:domain_manga/domain_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseScreenState extends Equatable {
  final SearchMangaParameter parameter;

  const BrowseScreenState({this.parameter = const SearchMangaParameter()});

  @override
  List<Object?> get props => [parameter];

  BrowseScreenState copyWith({SearchMangaParameter? parameter}) {
    return BrowseScreenState(parameter: parameter ?? this.parameter);
  }
}
