import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class DownloadChapterProgressStreamUseCase {
  ValueStream<(int, double)> downloadChapterProgressStream({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });
}