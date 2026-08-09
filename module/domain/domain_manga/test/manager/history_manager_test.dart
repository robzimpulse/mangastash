// HistoryManager should expose only history entries whose manga source is in
// the current enabled-sources set. The enabled set is streamed by
// ListenSourcesUseCase; tests inject a fake backed by a BehaviorSubject.
import 'dart:async';

import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/manager/history_manager.dart';
import 'package:entity_manga/entity_manga.dart';
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
      source: Value(index.isEven ? 'Manga Dex' : 'Asura Scans'),
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
      Sources.values.where((e) => e.name != 'Asura Scans').toList(),
    );

    final manager = HistoryManager(
      historyDao: historyDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    final result = await manager.readHistoryStream.first;

    expect(result.single.manga?.title, 'title_0');
  });

  test('readHistoryStream excludes history with a null manga source', () async {
    await seedHistory();

    final nullSourceManga = MangaTablesCompanion(
      id: const Value('manga_null_source'),
      title: const Value('title_null_source'),
      coverUrl: const Value('cover_url_null_source'),
      status: const Value('status_null_source'),
      author: const Value('author_null_source'),
      description: const Value('description_null_source'),
      webUrl: const Value('web_url_null_source'),
      source: const Value(null),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
    final nullSourceChapter = ChapterTablesCompanion(
      id: const Value('chapter_null_source'),
      mangaId: const Value('manga_null_source'),
      title: const Value('chapter_title_null_source'),
      chapter: const Value('0'),
      readableAt: Value(DateTime.now()),
      publishAt: Value(DateTime.now()),
      lastReadAt: Value(DateTime.now()),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
    await mangaDao.adds(values: {nullSourceManga: []});
    await chapterDao.adds(values: {nullSourceChapter: []});

    final manager = HistoryManager(
      historyDao: historyDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    final result = await manager.readHistoryStream.first;

    expect(result.map((e) => e.manga?.id), ['manga_0', 'manga_1']);
  });

  test(
    'readHistoryStream restores rows live when a source is re-enabled '
    'without any DB write',
    () async {
      await seedHistory();

      final manager = HistoryManager(
        historyDao: historyDao,
        listenSourcesUseCase: _FakeListenSources(enabledSources),
      );

      final controller = StreamController<List<MangaChapter>>.broadcast();
      final subscription = manager.readHistoryStream.listen(controller.add);

      enabledSources.add(
        Sources.values.where((e) => e.name != 'Asura Scans').toList(),
      );
      final hidden = await controller.stream.first;
      expect(hidden.map((e) => e.manga?.title), ['title_0']);

      enabledSources.add(Sources.values);
      final restored = await controller.stream.first;
      expect(restored.map((e) => e.manga?.title), ['title_0', 'title_1']);

      await subscription.cancel();
      await controller.close();
    },
  );
}

class _FakeListenSources implements ListenSourcesUseCase {
  _FakeListenSources(this._sources);

  final BehaviorSubject<List<SourceExternal>> _sources;

  @override
  ValueStream<List<SourceExternal>> get sourceStateStream => _sources.stream;
}
