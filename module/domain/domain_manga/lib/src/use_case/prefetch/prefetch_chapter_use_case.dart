abstract class PrefetchChapterUseCase {
  void prefetchChapters({
    required String mangaId,
    required String source,
  });

  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required String source,
  });
}
