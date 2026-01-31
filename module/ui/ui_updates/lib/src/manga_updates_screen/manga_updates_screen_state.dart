import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaUpdatesScreenState extends Equatable {
  final List<MangaChapter> updates;
  final Set<String> prefetchedChapterIds;

  const MangaUpdatesScreenState({
    this.updates = const [],
    this.prefetchedChapterIds = const {},
  });

  @override
  List<Object?> get props => [updates, prefetchedChapterIds];

  MangaUpdatesScreenState copyWith({
    List<MangaChapter>? updates,
    Set<String>? prefetchedChapterIds,
  }) {
    return MangaUpdatesScreenState(
      updates: updates ?? this.updates,
      prefetchedChapterIds: prefetchedChapterIds ?? this.prefetchedChapterIds,
    );
  }
}
