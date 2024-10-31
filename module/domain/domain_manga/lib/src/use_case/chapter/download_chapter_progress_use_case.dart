import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class DownloadChapterProgressUseCase {
  double downloadChapterProgress({
    required DownloadChapter key,
  });

  ValueStream<(int, double)> downloadChapterProgressStream({
    required DownloadChapter key,
  });
}