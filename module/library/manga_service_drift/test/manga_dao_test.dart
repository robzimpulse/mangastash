// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  // late AppDatabase db;
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
  //   mangaDao = MangaDao(db);
  // });
  //
  // tearDown(() => db.close());
  //
  // group('Manga Dao Test', () {
  //   tearDown(() => db.clear());
  //
  //   setUp(() async {
  //     for (final tag in tags) {
  //       await mangaDao.insertTag(tag);
  //     }
  //
  //     for (final manga in mangas) {
  //       await mangaDao.insertManga(manga);
  //     }
  //   });
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
  // });
}
