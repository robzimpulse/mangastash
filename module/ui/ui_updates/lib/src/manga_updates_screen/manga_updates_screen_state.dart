import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaUpdatesScreenState extends Equatable {
  final Map<Manga, List<Chapter>> updates;
  final List<Manga> libraries;
  final Set<String> prefetchedMangaIds;
  final Set<String> prefetchedChapterIds;

  const MangaUpdatesScreenState({
    this.updates = const {},
    this.libraries = const [],
    this.prefetchedMangaIds = const {},
    this.prefetchedChapterIds = const {},
  });

  @override
  List<Object?> get props => [
    updates,
    libraries,
    prefetchedChapterIds,
    prefetchedMangaIds,
  ];

  MangaUpdatesScreenState copyWith({
    Map<Manga, List<Chapter>>? updates,
    List<Manga>? libraries,
    Set<String>? prefetchedChapterIds,
    Set<String>? prefetchedMangaIds,
  }) {
    return MangaUpdatesScreenState(
      updates: updates ?? this.updates,
      libraries: libraries ?? this.libraries,
      prefetchedChapterIds: prefetchedChapterIds ?? this.prefetchedChapterIds,
      prefetchedMangaIds: prefetchedMangaIds ?? this.prefetchedMangaIds,
    );
  }
}
