import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaUpdatesScreenState extends Equatable {
  final List<MangaChapter> updates;
  final Set<String> prefetchedMangaIds;
  final Set<String> prefetchedChapterIds;

  const MangaUpdatesScreenState({
    this.updates = const [],
    this.prefetchedMangaIds = const {},
    this.prefetchedChapterIds = const {},
  });

  @override
  List<Object?> get props => [
    updates,
    prefetchedChapterIds,
    prefetchedMangaIds,
  ];

  MangaUpdatesScreenState copyWith({
    List<MangaChapter>? updates,
    Set<String>? prefetchedChapterIds,
    Set<String>? prefetchedMangaIds,
  }) {
    return MangaUpdatesScreenState(
      updates: updates ?? this.updates,
      prefetchedChapterIds: prefetchedChapterIds ?? this.prefetchedChapterIds,
      prefetchedMangaIds: prefetchedMangaIds ?? this.prefetchedMangaIds,
    );
  }
}
