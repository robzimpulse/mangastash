import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class SearchMangaScreenState extends Equatable {
  final String keyword;

  final List<SourceEnum> sources;

  const SearchMangaScreenState({
    this.keyword = '',
    this.sources = const [],
  });

  @override
  List<Object?> get props => [keyword, sources];

  SearchMangaScreenState copyWith({
    String? keyword,
    List<SourceEnum>? sources,
    Map<SourceEnum, SearchMangaParameter>? parameters,
    Map<SourceEnum, List<Manga>>? results,
  }) {
    return SearchMangaScreenState(
      keyword: keyword ?? this.keyword,
      sources: sources ?? this.sources,
    );
  }
}
