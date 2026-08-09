// LibraryManager should expose only library manga whose source is in the
// current enabled-sources set. The enabled set is streamed by
// ListenSourcesUseCase; tests inject a fake backed by a BehaviorSubject.
import 'dart:async';

import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/manager/library_manager.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  late AppDatabase db;
  late LibraryDao libraryDao;
  late MangaDao mangaDao;
  late BehaviorSubject<List<SourceExternal>> enabledSources;

  final mangas = List.generate(
    4,
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

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    libraryDao = LibraryDao(db);
    mangaDao = MangaDao(db);
    enabledSources = BehaviorSubject.seeded(Sources.values);
  });

  tearDown(() async {
    await enabledSources.close();
    await db.close();
  });

  Future<LibraryManager> makeManager() async {
    for (final manga in mangas) {
      await mangaDao.adds(values: {manga: []});
      await libraryDao.add(manga.id.value);
    }
    return LibraryManager(
      libraryDao: libraryDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );
  }

  test('libraryStateStream filters out disabled-source manga', () async {
    enabledSources.add(
      Sources.values.where((e) => e.name != 'Asura Scans').toList(),
    );

    final manager = await makeManager();

    final result = await manager.libraryStateStream.first;

    expect(result.map((e) => e.title), ['title_0', 'title_2']);
  });

  test('libraryMangaIds excludes disabled-source manga ids', () async {
    enabledSources.add(
      Sources.values.where((e) => e.name != 'Asura Scans').toList(),
    );

    final manager = await makeManager();

    final result = await manager.libraryMangaIds.first;

    expect(result, {'manga_0', 'manga_2'});
  });

  test('libraryStateStream excludes manga with a null source', () async {
    await makeManager();

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
    await mangaDao.adds(values: {nullSourceManga: []});
    await libraryDao.add(nullSourceManga.id.value);

    final manager = LibraryManager(
      libraryDao: libraryDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    final result = await manager.libraryStateStream.first;

    expect(result.map((e) => e.id), mangas.map((e) => e.id.value));
  });

  test(
    'libraryStateStream restores rows live when a source is re-enabled '
    'without any DB write',
    () async {
      final manager = await makeManager();

      final controller = StreamController<List<Manga>>.broadcast();
      final subscription = manager.libraryStateStream.listen(controller.add);

      // Disable AsuraScan; its row drops from the stream.
      enabledSources.add(
        Sources.values.where((e) => e.name != 'Asura Scans').toList(),
      );
      final hidden = await controller.stream.first;
      expect(hidden.map((e) => e.id).toList(), ['manga_0', 'manga_2']);

      // Re-enable AsuraScan with no DB write; the row reappears.
      enabledSources.add(Sources.values);
      final restored = await controller.stream.first;
      expect(
        restored.map((e) => e.id).toList(),
        ['manga_0', 'manga_1', 'manga_2', 'manga_3'],
      );

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
