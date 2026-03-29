import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';

class BrowseScreenState extends Equatable {
  final SearchMangaParameter parameter;

  final List<SourceExternal> sources;

  const BrowseScreenState({
    this.parameter = const SearchMangaParameter(),
    this.sources = const [],
  });

  @override
  List<Object?> get props => [parameter, sources];

  BrowseScreenState copyWith({
    SearchMangaParameter? parameter,
    List<SourceExternal>? sources,
  }) {
    return BrowseScreenState(
      parameter: parameter ?? this.parameter,
      sources: sources ?? this.sources,
    );
  }
}
