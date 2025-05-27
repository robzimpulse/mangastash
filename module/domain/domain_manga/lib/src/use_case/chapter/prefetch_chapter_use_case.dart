import 'package:entity_manga/entity_manga.dart';

abstract class PrefetchChapterUseCase {
  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required MangaSourceEnum source,
  });
}
