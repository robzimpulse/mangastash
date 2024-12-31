import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenActiveDownloadUseCase {
  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>> get activeDownloadStream;
}