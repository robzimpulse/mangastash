import 'package:entity_manga_external/entity_manga_external.dart';

abstract class PrefetchChapterUseCase {
  void prefetchChapters({
    required String mangaId,
    required SourceExternal source,
  });

  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required SourceExternal source,
  });
}
