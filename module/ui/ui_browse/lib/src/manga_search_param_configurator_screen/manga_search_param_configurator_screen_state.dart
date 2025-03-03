import 'package:domain_manga/domain_manga.dart';
import 'package:equatable/equatable.dart';

class MangaSearchParamConfiguratorScreenState extends Equatable {
  final SearchMangaParameter? original;

  final SearchMangaParameter? modified;

  const MangaSearchParamConfiguratorScreenState({
    this.original,
    this.modified,
  });

  @override
  List<Object?> get props => [
        original,
        modified,
      ];

  MangaSearchParamConfiguratorScreenState copyWith({
    SearchMangaParameter? original,
    SearchMangaParameter? modified,
  }) {
    return MangaSearchParamConfiguratorScreenState(
      original: original ?? this.original,
      modified: modified ?? this.modified,
    );
  }
}
