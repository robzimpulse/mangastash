import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/streams.dart';

abstract class DownloadChapterUseCase {
  void downloadChapter({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });

  ValueStream<(int, double)> downloadChapterProgressStream({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });

  double downloadChapterProgress({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });
}
