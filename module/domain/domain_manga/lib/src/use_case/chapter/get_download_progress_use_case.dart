import 'package:background_downloader/background_downloader.dart';
import 'package:entity_manga/entity_manga.dart';

class GetDownloadProgressUseCase {
  final FileDownloader _fileDownloader;

  GetDownloadProgressUseCase({
    required FileDownloader fileDownloader,
  }) : _fileDownloader = fileDownloader;

  Future<double> execute({required DownloadChapterKey key}) async {
    final group = key.toJsonString();
    final records = await _fileDownloader.database.allRecords(group: group);
    final total = records.fold(0.0, (total, record) => total + record.progress);
    return total / records.length;
  }
}
