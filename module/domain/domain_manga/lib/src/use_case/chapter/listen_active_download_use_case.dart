import 'package:rxdart/rxdart.dart';

import '../../../domain_manga.dart';

abstract class ListenActiveDownloadUseCase {
  ValueStream<Set<DownloadChapterKey>> get activeDownloadStream;
}