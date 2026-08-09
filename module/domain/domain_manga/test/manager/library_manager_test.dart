// LibraryManager should expose only library manga whose source is in the
// current enabled-sources set. The enabled set is streamed by
// ListenSourcesUseCase; tests inject a fake backed by a BehaviorSubject.
import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/manager/library_manager.dart';
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
      source: Value(index.isEven ? 'Manga Dex' : 'AsuraScan'),
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
      Sources.values.where((e) => e.name != 'AsuraScan').toList(),
    );

    final manager = await makeManager();

    final result = await manager.libraryStateStream.first;

    expect(result.map((e) => e.title), ['title_0', 'title_2']);
  });

  test('libraryMangaIds excludes disabled-source manga ids', () async {
    enabledSources.add(
      Sources.values.where((e) => e.name != 'AsuraScan').toList(),
    );

    final manager = await makeManager();

    final result = await manager.libraryMangaIds.first;

    expect(result, {'manga_0', 'manga_2'});
  });
}

class _FakeListenSources implements ListenSourcesUseCase {
  _FakeListenSources(this._sources);

  final BehaviorSubject<List<SourceExternal>> _sources;

  @override
  ValueStream<List<SourceExternal>> get sourceStateStream => _sources.stream;
}
