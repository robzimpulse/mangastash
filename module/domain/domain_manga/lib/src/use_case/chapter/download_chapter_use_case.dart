import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/streams.dart';

import '../../typedef/download_chapter_keys_typedef.dart';

abstract class DownloadChapterUseCase {
  void downloadChapter({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });

  Map<DownloadChapterKey, BehaviorSubject<(int, double)>> get progress;
}
