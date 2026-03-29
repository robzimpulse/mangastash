import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';

class SearchMangaScreenState extends Equatable {
  final SearchMangaParameter parameter;
  final Set<SourceExternal> sources;

  const SearchMangaScreenState({
    this.parameter = const SearchMangaParameter(),
    this.sources = const {},
  });

  @override
  List<Object?> get props => [
    parameter,
    sources,
  ];

  SearchMangaScreenState copyWith({
    SearchMangaParameter? parameter,
    Set<SourceExternal>? sources,
  }) {
    return SearchMangaScreenState(
      parameter: parameter ?? this.parameter,
      sources: sources ?? this.sources,
    );
  }
}
