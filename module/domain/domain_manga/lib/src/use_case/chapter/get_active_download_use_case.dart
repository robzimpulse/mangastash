import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';

class GetActiveDownloadUseCase {
  final FileDownloader _fileDownloader;

  GetActiveDownloadUseCase({
    required FileDownloader fileDownloader,
  }) : _fileDownloader = fileDownloader;

  Future<List<DownloadChapterKey>> execute() async {
    final records = await _fileDownloader.database.allRecords();
    final group = records.groupListsBy((record) => record.group)
      ..removeWhere(
        (key, value) => value.every((record) => record.status.isFinalState),
      );
    return group.keys.map((e) => DownloadChapterKey.fromJsonString(e)).toList();
  }
}
