// HistoryManager should expose only history entries whose manga source is in
// the current enabled-sources set. The enabled set is streamed by
// ListenSourcesUseCase; tests inject a fake backed by a BehaviorSubject.
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/manager/history_manager.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  late AppDatabase db;
  late HistoryDao historyDao;
  late MangaDao mangaDao;
  late ChapterDao chapterDao;
  late BehaviorSubject<List<SourceExternal>> enabledSources;

  final mangas = List.generate(
    2,
    (index) => MangaTablesCompanion(
      id: Value('manga_$index'),
      title: Value('title_$index'),
      coverUrl: Value('cover_url_$index'),
      status: Value('status_$index'),
      author: Value('author_$index'),
      description: Value('description_$index'),
      webUrl: Value('web_url_$index'),
      source: Value(index.isEven ? 'Manga Dex' : 'AsuraScan'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  final chapters = List.generate(
    2,
    (index) => ChapterTablesCompanion(
      id: Value('chapter_$index'),
      mangaId: Value('manga_$index'),
      title: Value('chapter_title_$index'),
      chapter: Value('$index'),
      readableAt: Value(DateTime.now()),
      publishAt: Value(DateTime.now()),
      lastReadAt: Value(DateTime.now()),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    historyDao = HistoryDao(db);
    mangaDao = MangaDao(db);
    chapterDao = ChapterDao(db);
    enabledSources = BehaviorSubject.seeded(Sources.values);
  });

  tearDown(() async {
    await enabledSources.close();
    await db.close();
  });

  Future<void> seedHistory() async {
    for (var i = 0; i < 2; i++) {
      await mangaDao.adds(values: {mangas[i]: []});
      // Chapters carry lastReadAt, so inserting them surfaces in the
      // history stream (filtered on lastReadAt.isNotNull()).
      await chapterDao.adds(values: {chapters[i]: []});
    }
  }

  test('readHistoryStream filters disabled-source history', () async {
    await seedHistory();
    enabledSources.add(
      Sources.values.where((e) => e.name != 'AsuraScan').toList(),
    );

    final manager = HistoryManager(
      historyDao: historyDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    final result = await manager.readHistoryStream.first;

    expect(result.single.manga?.title, 'title_0');
  });
}

class _FakeListenSources implements ListenSourcesUseCase {
  _FakeListenSources(this._sources);

  final BehaviorSubject<List<SourceExternal>> _sources;

  @override
  ValueStream<List<SourceExternal>> get sourceStateStream => _sources.stream;
}
