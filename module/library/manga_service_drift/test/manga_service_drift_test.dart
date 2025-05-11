import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  late AppDatabase db;
  late SyncMangasDao syncMangasDao;

  setUp(() {
    db = AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    syncMangasDao = SyncMangasDao(db);
  });

  tearDown(() => db.close());

  group('Insert', () {
    test('New Manga', () async {
      const manga = MangaDrift(
        title: 'title',
        author: 'author',
        coverUrl: 'coverUrl',
        status: 'status',
        description: 'description',
        webUrl: 'webUrl',
        source: 'source',
        tags: [
          MangaTagDrift(
            name: 'Test',
          ),
        ],
      );

      await syncMangasDao.sync([manga]);

      {
        final data = await db.select(db.mangaTables).get();
        expect(data.length, equals(1));
      }

      {
        final data = await db.select(db.mangaTagTables).get();
        expect(data.length, equals(1));
      }

      {
        final data = await db.select(db.mangaTagRelationshipTables).get();
        expect(data.length, equals(1));
      }
    });

    test('Existing Manga', () async {
      const manga = MangaDrift(
        id: 'id',
        title: 'title',
        author: 'author',
        coverUrl: 'coverUrl',
        status: 'status',
        description: 'description',
        webUrl: 'webUrl',
        source: 'source',
        tags: [
          MangaTagDrift(
            id: 'id',
            name: 'Test',
          ),
        ],
      );

      await syncMangasDao.sync([manga]);

      {
        final data = await db.select(db.mangaTables).get();
        expect(data.length, equals(1));
      }

      {
        final data = await db.select(db.mangaTagTables).get();
        expect(data.length, equals(1));
      }

      {
        final data = await db.select(db.mangaTagRelationshipTables).get();
        expect(data.length, equals(1));
      }
    });
  });

  group('Update', () {
    const existing = MangaDrift(
      id: 'testing',
      title: 'title',
      author: 'author',
      coverUrl: 'coverUrl',
      status: 'status',
      description: 'description',
      webUrl: 'webUrl',
      source: 'source',
      tags: [
        MangaTagDrift(
          id: 'testing',
          name: 'Test',
        ),
      ],
    );

    setUp(() async => await syncMangasDao.sync([existing]));

    test('Manga can be updated', () async {
      final updated = existing.toCompanion();
      await syncMangasDao.sync(
        [
          MangaDrift.fromCompanion(
            updated.copyWith(
              title: const Value('title_updated'),
            ),
            existing.tags
                .map(
                  (e) => e
                      .toCompanion()
                      .copyWith(name: const Value('name_updated')),
                )
                .toList(),
          ),
        ],
      );

      {
        final data = await db.select(db.mangaTables).get();
        expect(data.length, equals(1));
      }

      {
        final data = await db.select(db.mangaTagTables).get();
        expect(data.length, equals(1));
      }

      {
        final data = await db.select(db.mangaTagRelationshipTables).get();
        expect(data.length, equals(1));
      }

    });
  });
}
