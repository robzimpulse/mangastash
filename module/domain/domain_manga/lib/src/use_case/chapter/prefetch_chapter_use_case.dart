import 'package:entity_manga/entity_manga.dart';

abstract class PrefetchChapterUseCase {
  void prefetchChapters({
    required String mangaId,
    required MangaSourceEnum source,
  });

  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required MangaSourceEnum source,
  });
}
