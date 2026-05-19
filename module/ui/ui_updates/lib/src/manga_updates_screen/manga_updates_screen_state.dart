import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';

class MangaUpdatesScreenState extends Equatable {
  final List<MangaChapter> updates;
  final Set<String> prefetchedChapterIds;
  final Map<String, SourceExternal?> sources;

  const MangaUpdatesScreenState({
    this.updates = const [],
    this.prefetchedChapterIds = const {},
    this.sources = const {},
  });

  @override
  List<Object?> get props => [updates, prefetchedChapterIds, sources];

  MangaUpdatesScreenState copyWith({
    List<MangaChapter>? updates,
    Set<String>? prefetchedChapterIds,
    Map<String, SourceExternal?>? sources,
  }) {
    return MangaUpdatesScreenState(
      updates: updates ?? this.updates,
      prefetchedChapterIds: prefetchedChapterIds ?? this.prefetchedChapterIds,
      sources: sources ?? this.sources,
    );
  }
}
