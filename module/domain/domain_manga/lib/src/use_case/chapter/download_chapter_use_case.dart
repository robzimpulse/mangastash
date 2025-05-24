import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../../domain_manga.dart';
import '../../mixin/generate_task_id_mixin.dart';

class DownloadChapterUseCase with GenerateTaskIdMixin, UserAgentMixin {
  final LogBox _log;
  final FetchChapterJobDao _fetchChapterJobDao;

  DownloadChapterUseCase({
    required LogBox log,
    required FetchChapterJobDao fetchChapterJobDao,
  })  : _log = log,
        _fetchChapterJobDao = fetchChapterJobDao;

  Future<void> execute({required DownloadChapterKey key}) async {
    final info = '${key.mangaTitle} - chapter ${key.chapterNumber}';

    _log.log(
      '[$info] Enqueue job to fetch chapter images',
      name: runtimeType.toString(),
    );

    await _fetchChapterJobDao.add(key.toDrift);
  }
}
