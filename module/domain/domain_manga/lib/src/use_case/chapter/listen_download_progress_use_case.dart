import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenDownloadProgressUseCase {
  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>> progress(
    List<DownloadChapterKey> key,
  );

  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>> get active;

  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>> get all;
}
