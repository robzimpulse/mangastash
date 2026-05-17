import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';

class MangaHistoryScreenState extends Equatable {
  final List<MangaChapter> histories;
  final Map<String, SourceExternal?> sources;

  const MangaHistoryScreenState({
    this.histories = const [],
    this.sources = const {},
  });

  @override
  List<Object?> get props => [histories, sources];

  MangaHistoryScreenState copyWith({
    List<MangaChapter>? histories,
    Map<String, SourceExternal?>? sources,
  }) {
    return MangaHistoryScreenState(
      histories: histories ?? this.histories,
      sources: sources ?? this.sources,
    );
  }
}
