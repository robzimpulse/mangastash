import 'package:entity_manga/entity_manga.dart';

abstract class PrefetchChapterUseCase {
  void prefetchChapters({required String mangaId, required SourceEnum source});

  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required SourceEnum source,
  });
}
