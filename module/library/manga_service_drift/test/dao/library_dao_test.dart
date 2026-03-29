import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

void main() {
  late AppDatabase db;
  late LibraryDao libraryDao;
  late MangaDao mangaDao;
  late TagDao tagDao;

  final mangas = List.generate(
    10,
    (index) => MangaTablesCompanion(
      id: Value('manga_$index'),
      title: Value('title_$index'),
      coverUrl: Value('cover_url_$index'),
      status: Value('status_$index'),
      author: Value('author_$index'),
      description: Value('description_$index'),
      webUrl: Value('web_url_$index'),
      source: Value('source_$index'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  final tags = List.generate(
    10,
    (index) => TagTablesCompanion(
      id: Value(index + 1),
      tagId: Value('tag_$index'),
      name: Value('name_$index'),
      source: const Value('source'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    libraryDao = LibraryDao(db);
    mangaDao = MangaDao(db);
    tagDao = TagDao(db);
  });

  tearDown(() => db.close());

  group('Library Dao Test', () {
    tearDown(() => db.clear());

    setUp(() async {
      await tagDao.adds(values: tags);

      for (final (index, manga) in mangas.indexed) {
        await mangaDao.adds(values: {manga: []});
        if (index.isEven) await libraryDao.add(manga.id.value);
      }
    });

    group('Get Library', () {
      test('With Non Empty Tags', () async {
        for (final manga in mangas) {
          await tagDao.detach(mangaId: manga.id.value);
          for (final tag in tags) {
            await tagDao.attach(mangaId: manga.id.value, tagId: tag.id.value);
          }
        }

        final result = await libraryDao.stream.first;
        expect(result.isNotEmpty, isTrue);
        
        final streams = await libraryDao.stream.first;
        expect(streams.isNotEmpty, isTrue);
      });

      test('With Empty Tags', () async {
        final result = await libraryDao.stream.first;
        expect(result.isNotEmpty, isTrue);
        
        // Test remove
        await libraryDao.remove(mangas.first.id.value);
        final afterRemove = await libraryDao.stream.first;
        expect(afterRemove.length, lessThan(result.length));
      });
    });
  });
}
