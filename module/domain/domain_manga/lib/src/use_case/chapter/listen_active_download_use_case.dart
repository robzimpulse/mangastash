import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenActiveDownloadUseCase {
  ValueStream<Set<DownloadChapter>> get activeDownloadStream;
}