import 'package:entity_manga/src/manga_chapter_config.dart';
import 'package:rxdart/rxdart.dart';

import 'listen_manga_chapter_config.dart';
import 'update_manga_chapter_config.dart';

class MangaChapterConfigManager implements ListenMangaChapterConfig, UpdateMangaChapterConfig {
  MangaChapterConfigManager();

  final _configDataStream = BehaviorSubject<MangaChapterConfig>.seeded(
    const MangaChapterConfig(),
  );

  @override
  ValueStream<MangaChapterConfig> get mangaChapterConfigStream =>
      _configDataStream.stream;

  @override
  void updateMangaChapterConfig({required MangaChapterConfig config}) {
    _configDataStream.add(config);
  }
}
