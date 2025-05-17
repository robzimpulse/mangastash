void main() {
  // late AppDatabase db;
  // late SyncMangasDao syncMangasDao;
  // late SyncChaptersDao syncChaptersDao;
  //
  // setUp(() {
  //   db = AppDatabase(
  //     executor: DatabaseConnection(
  //       NativeDatabase.memory(),
  //       closeStreamsSynchronously: true,
  //     ),
  //   );
  //   syncMangasDao = SyncMangasDao(db);
  //   syncChaptersDao = SyncChaptersDao(db);
  // });
  //
  // tearDown(() => db.close());
  //
  // group('Insert', () {
  //   test('New Manga', () async {
  //     const manga = MangaDrift(
  //       title: 'title',
  //       author: 'author',
  //       coverUrl: 'coverUrl',
  //       status: 'status',
  //       description: 'description',
  //       webUrl: 'webUrl',
  //       source: 'source',
  //       tags: [
  //         MangaTagDrift(
  //           name: 'Test',
  //         ),
  //       ],
  //     );
  //
  //     await syncMangasDao.sync([manga]);
  //
  //     {
  //       final data = await db.select(db.mangaTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaTagTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaTagRelationshipTables).get();
  //       expect(data.length, equals(1));
  //     }
  //   });
  //
  //   test('Existing Manga', () async {
  //     const manga = MangaDrift(
  //       id: 'id',
  //       title: 'title',
  //       author: 'author',
  //       coverUrl: 'coverUrl',
  //       status: 'status',
  //       description: 'description',
  //       webUrl: 'webUrl',
  //       source: 'source',
  //       tags: [
  //         MangaTagDrift(
  //           id: 'id',
  //           name: 'Test',
  //         ),
  //       ],
  //     );
  //
  //     await syncMangasDao.sync([manga]);
  //
  //     {
  //       final data = await db.select(db.mangaTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaTagTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaTagRelationshipTables).get();
  //       expect(data.length, equals(1));
  //     }
  //   });
  //
  //   test('New Chapter', () async {
  //     const chapter = MangaChapterDrift(
  //       title: 'title',
  //       volume: 'volume',
  //       chapter: 'chapter',
  //       webUrl: 'webUrl',
  //       scanlationGroup: 'scanlation_group',
  //       translatedLanguage: 'translation_language',
  //       readableAt: 'readable_at',
  //       publishAt: 'publish_at',
  //       images: [
  //         MangaChapterImageDrift(
  //           webUrl: 'image1',
  //         ),
  //         MangaChapterImageDrift(
  //           webUrl: 'image2',
  //         ),
  //         MangaChapterImageDrift(
  //           webUrl: 'image3',
  //         ),
  //       ],
  //     );
  //
  //     await syncChaptersDao.sync([chapter]);
  //
  //     {
  //       final data = await db.select(db.mangaChapterTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaChapterImageTables).get();
  //       expect(data.length, equals(3));
  //     }
  //   });
  //
  //   test('Existing Chapter', () async {
  //     const chapter = MangaChapterDrift(
  //       id: 'id',
  //       title: 'title',
  //       volume: 'volume',
  //       chapter: 'chapter',
  //       webUrl: 'webUrl',
  //       scanlationGroup: 'scanlation_group',
  //       translatedLanguage: 'translation_language',
  //       readableAt: 'readable_at',
  //       publishAt: 'publish_at',
  //       images: [
  //         MangaChapterImageDrift(
  //           id: 'id1',
  //           webUrl: 'image1',
  //         ),
  //         MangaChapterImageDrift(
  //           id: 'id2',
  //           webUrl: 'image2',
  //         ),
  //         MangaChapterImageDrift(
  //           id: 'id3',
  //           webUrl: 'image3',
  //         ),
  //       ],
  //     );
  //
  //     await syncChaptersDao.sync([chapter]);
  //
  //     {
  //       final data = await db.select(db.mangaChapterTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaChapterImageTables).get();
  //       expect(data.length, equals(3));
  //     }
  //   });
  // });
  //
  // group('Update', () {
  //   const existingManga = MangaDrift(
  //     id: 'testing',
  //     title: 'title',
  //     author: 'author',
  //     coverUrl: 'coverUrl',
  //     status: 'status',
  //     description: 'description',
  //     webUrl: 'webUrl',
  //     source: 'source',
  //     tags: [
  //       MangaTagDrift(
  //         id: 'testing',
  //         name: 'Test',
  //       ),
  //     ],
  //   );
  //
  //   const existingChapter = MangaChapterDrift(
  //     id: 'testing',
  //     mangaId: 'testing',
  //     mangaTitle: 'manga_title',
  //     title: 'title',
  //     volume: 'volume',
  //     chapter: 'chapter',
  //     webUrl: 'webUrl',
  //     scanlationGroup: 'scanlation_group',
  //     translatedLanguage: 'translation_language',
  //     readableAt: 'readable_at',
  //     publishAt: 'publish_at',
  //     images: [
  //       MangaChapterImageDrift(
  //         id: 'testing',
  //         chapterId: 'testing',
  //         webUrl: 'image',
  //       ),
  //     ],
  //   );
  //
  //   setUp(() async {
  //     await syncMangasDao.sync([existingManga]);
  //     await syncChaptersDao.sync([existingChapter]);
  //   });
  //
  //   test('Manga can be updated', () async {
  //     final updated = existingManga.toCompanion();
  //     await syncMangasDao.sync(
  //       [
  //         MangaDrift.fromCompanion(
  //           updated.copyWith(
  //             title: const Value('title_updated'),
  //           ),
  //           existingManga.tags
  //               .map(
  //                 (e) => e
  //                     .toCompanion()
  //                     .copyWith(name: const Value('name_updated')),
  //               )
  //               .toList(),
  //         ),
  //       ],
  //     );
  //
  //     {
  //       final data = await db.select(db.mangaTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaTagTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaTagRelationshipTables).get();
  //       expect(data.length, equals(1));
  //     }
  //   });
  //
  //   test('Chapter can be updated', () async {
  //     final updated = existingChapter.toCompanion();
  //
  //     await syncChaptersDao.sync(
  //       [
  //         MangaChapterDrift.fromCompanion(
  //           updated.copyWith(
  //             title: const Value('title_updated'),
  //           ),
  //           images: existingChapter.images
  //               .map(
  //                 (e) => e
  //                     .toCompanion()
  //                     .copyWith(webUrl: const Value('web_url_updated')),
  //               )
  //               .toList(),
  //         ),
  //       ],
  //     );
  //
  //     {
  //       final data = await db.select(db.mangaChapterTables).get();
  //       expect(data.length, equals(1));
  //     }
  //
  //     {
  //       final data = await db.select(db.mangaChapterImageTables).get();
  //       expect(data.length, equals(1));
  //     }
  //   });
  // });
}
