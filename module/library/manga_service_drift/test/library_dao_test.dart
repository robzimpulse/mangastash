import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  // late AppDatabase db;
  // late LibraryDao libraryDao;
  // late MangaDao mangaDao;
  //
  // final mangas = List.generate(
  //   10,
  //   (index) => MangaTablesCompanion(
  //     id: Value('manga_$index'),
  //     title: Value('title_$index'),
  //     coverUrl: Value('cover_url_$index'),
  //     status: Value('status_$index'),
  //     author: Value('value_$index'),
  //     description: Value('description_$index'),
  //     webUrl: Value('web_url_$index'),
  //     source: Value('source_$index'),
  //   ),
  // );
  //
  // final tags = List.generate(
  //   10,
  //   (index) => TagTablesCompanion(
  //     id: Value('tag_$index'),
  //     name: Value('name_$index'),
  //   ),
  // );
  //
  // setUp(() {
  //   db = AppDatabase(
  //     executor: DatabaseConnection(
  //       NativeDatabase.memory(),
  //       closeStreamsSynchronously: true,
  //     ),
  //   );
  //   libraryDao = LibraryDao(db);
  //   mangaDao = MangaDao(db);
  // });
  //
  // tearDown(() => db.close());
  //
  // group('Library Dao Test', () {
  //   tearDown(() => db.clear());
  //
  //   setUp(() async {
  //     for (final tag in tags) {
  //       await mangaDao.insertTag(tag);
  //     }
  //
  //     for (final (index, manga) in mangas.indexed) {
  //       await mangaDao.insertManga(manga);
  //       if (index.isEven) await libraryDao.add(manga.id.value);
  //     }
  //   });
  //
  //   group('Get Library', () {
  //     test('With Non Empty Tags', () async {
  //       for (final manga in mangas) {
  //         await mangaDao.unlinkAllTagFromManga(manga.id.value);
  //         await mangaDao.linkTagToManga(
  //           manga.id.value,
  //           tags.map((e) => e.id.value),
  //         );
  //       }
  //
  //       final result = await libraryDao.get();
  //       expect(result.isNotEmpty, isTrue);
  //     });
  //
  //     test('With Empty Tags', () async {
  //       final result = await libraryDao.get();
  //       expect(result.isNotEmpty, isTrue);
  //     });
  //   });
  // });
}
