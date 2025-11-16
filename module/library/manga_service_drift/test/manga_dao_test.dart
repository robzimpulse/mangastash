import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  late AppDatabase db;
  late MangaDao dao;

  final mangas = List.generate(
    10,
    (mangaIdx) => (
      MangaTablesCompanion(
        id: Value('manga_$mangaIdx'),
        title: Value('title_$mangaIdx'),
        coverUrl: Value('cover_url_$mangaIdx'),
        status: Value('status_$mangaIdx'),
        author: Value('value_$mangaIdx'),
        description: Value('description_$mangaIdx'),
        webUrl: Value('web_url_$mangaIdx'),
        source: Value('source_$mangaIdx'),
      ),
      List.generate(10, (index) => 'name_$index'),
    ),
  );

  setUp(() {
    db = AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    dao = MangaDao(db);
  });

  tearDown(() => db.close());

  group('Manga Dao Test', () {
    setUp(() async {
      await dao.adds(values: {for (final manga in mangas) manga.$1: manga.$2});
    });
    //
    //   group('Get Manga', () {
    //     test('With Non Empty Tags', () async {
    //       for (final manga in mangas) {
    //         await mangaDao.unlinkAllTagFromManga(manga.id.value);
    //         await mangaDao.linkTagToManga(
    //           manga.id.value,
    //           tags.map((e) => e.id.value),
    //         );
    //       }
    //
    //       final result = await mangaDao.getManga('manga_0');
    //       expect(result != null, isTrue);
    //       expect(result?.$1.id, 'manga_0');
    //       expect(result?.$2.length, 10);
    //     });
    //
    //     test('With Empty Tags', () async {
    //       final result = await mangaDao.getManga('manga_0');
    //       expect(result != null, isTrue);
    //       expect(result?.$1.id, 'manga_0');
    //       expect(result?.$2.length, 0);
    //     });
    //   });
  });
}
