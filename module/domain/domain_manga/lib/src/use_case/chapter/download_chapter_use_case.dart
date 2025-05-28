import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../../domain_manga.dart';
import '../../mixin/generate_task_id_mixin.dart';

class DownloadChapterUseCase with GenerateTaskIdMixin, UserAgentMixin {
  final LogBox _log;
  final DownloadJobDao _downloadJobDao;

  DownloadChapterUseCase({
    required LogBox log,
    required DownloadJobDao downloadJobDao,
  })  : _log = log,
        _downloadJobDao = downloadJobDao;

  Future<void> execute({required DownloadChapterKey key}) async {
    final info = '${key.mangaTitle} - chapter ${key.chapterNumber}';

    _log.log(
      '[$info] Enqueue job to fetch chapter images',
      name: runtimeType.toString(),
    );

    await _downloadJobDao.add(key.toDrift);
  }
}
