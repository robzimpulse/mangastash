import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaSearchParamConfiguratorScreenState extends Equatable {
  final SearchMangaParameter? original;

  final SearchMangaParameter? modified;

  final List<Tag> tags;

  const MangaSearchParamConfiguratorScreenState({
    this.original,
    this.modified,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        original,
        modified,
        tags,
      ];

  MangaSearchParamConfiguratorScreenState copyWith({
    SearchMangaParameter? original,
    SearchMangaParameter? modified,
    List<Tag>? tags,
  }) {
    return MangaSearchParamConfiguratorScreenState(
      original: original ?? this.original,
      modified: modified ?? this.modified,
      tags: tags ?? this.tags,
    );
  }
}
