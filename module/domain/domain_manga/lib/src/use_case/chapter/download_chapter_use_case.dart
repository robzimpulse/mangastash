import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/streams.dart';

abstract class DownloadChapterUseCase {
  Future<ValueStream<double>?> downloadChapter({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });
}
