// Add/RemoveFromLibraryUseCase must refuse (no DB write) while the manga's
// source is disabled: the managers filter disabled-source rows out of the
// library streams, so an unconditional remove would permanently delete a row
// the user can still see once the source is re-enabled, and an unconditional
// add would create an invisible row. Guards use the enabled set streamed by
// ListenSourcesUseCase.
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
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

  Future<void> seedManga(Manga manga) async {
    await mangaDao.adds(values: {manga.toDrift: const <String>[]});
  }

  Manga disabledManga() => const Manga(id: 'manga_0', source: 'Asura Scans');

  test('remove is refused while source is disabled and row survives', () async {
    final manga = disabledManga();
    await seedManga(manga);
    await libraryDao.add(manga.id!);

    // Disable Asura Scans.
    enabledSources.add(
      Sources.values.where((e) => e.name != 'Asura Scans').toList(),
    );

    final useCase = RemoveFromLibraryUseCase(
      libraryDao: libraryDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    final result = await useCase.execute(manga: manga);

    expect(result, isA<Error<bool>>());
    // Row survives the refused remove.
    final remaining = await libraryDao.stream.first;
    expect(remaining.map((e) => e.manga?.id), ['manga_0']);
  });

  test('add is refused while source is disabled and no row is written',
      () async {
    final manga = disabledManga();
    await seedManga(manga);

    enabledSources.add(
      Sources.values.where((e) => e.name != 'Asura Scans').toList(),
    );

    final useCase = AddToLibraryUseCase(
      libraryDao: libraryDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    final result = await useCase.execute(manga: manga);

    expect(result, isA<Error<bool>>());
    final rows = await libraryDao.stream.first;
    expect(rows, isEmpty);
  });

  test('remove and add succeed while source is enabled', () async {
    final manga = disabledManga();
    await seedManga(manga);

    final remove = RemoveFromLibraryUseCase(
      libraryDao: libraryDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );
    final add = AddToLibraryUseCase(
      libraryDao: libraryDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    expect(await add.execute(manga: manga), isA<Success<bool>>());
    var rows = await libraryDao.stream.first;
    expect(rows.map((e) => e.manga?.id), ['manga_0']);

    expect(await remove.execute(manga: manga), isA<Success<bool>>());
    rows = await libraryDao.stream.first;
    expect(rows, isEmpty);
  });
}

class _FakeListenSources implements ListenSourcesUseCase {
  _FakeListenSources(this._sources);

  final BehaviorSubject<List<SourceExternal>> _sources;

  @override
  ValueStream<List<SourceExternal>> get sourceStateStream => _sources.stream;
}
