import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class SearchMangaScreenState extends Equatable {
  final SearchMangaParameter parameter;
  final Set<SourceEnum> sources;

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
    Set<SourceEnum>? sources,
  }) {
    return SearchMangaScreenState(
      parameter: parameter ?? this.parameter,
      sources: sources ?? this.sources,
    );
  }
}
