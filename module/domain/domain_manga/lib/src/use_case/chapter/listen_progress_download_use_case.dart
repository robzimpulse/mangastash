import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenProgressDownloadUseCase {
  ValueStream<DownloadChapterProgress> progress(DownloadChapterKey key);
}