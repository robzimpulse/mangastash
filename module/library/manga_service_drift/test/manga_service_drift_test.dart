import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  late AppDatabase database;
  late SyncMangasDao syncMangasDao;

  setUp(() {
    database = AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    syncMangasDao = SyncMangasDao(database);
  });

  tearDown(() => database.close());

  test('manga can be inserted', () async {
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
      final data = await database.select(database.mangaTables).get();
      expect(data.length, equals(1));
    }

    {
      final data = await database.select(database.mangaTagTables).get();
      expect(data.length, equals(1));
    }

    // {
    //   final data = await database.select(database.mangaTagRelationshipTables).get();
    //   expect(data.length, equals(1));
    // }
  });

  test('manga can be updated', () async {
    const ori = MangaDrift(
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
          name: 'Test',
        ),
      ],
    );

    await syncMangasDao.sync([ori]);

    const updated = MangaDrift(
      id: 'testing',
      title: 'title_updated',
      author: 'author_updated',
      coverUrl: 'coverUrl_updated',
      status: 'status_updated',
      description: 'description_updated',
      webUrl: 'webUrl_updated',
      source: 'source_updated',
    );

    await syncMangasDao.sync([updated]);

    {
      final data = await database.select(database.mangaTables).get();
      expect(data.length, equals(1));
    }

    {
      final data = await database.select(database.mangaTagTables).get();
      expect(data.length, equals(1));
    }

    // {
    //   final data = await database.select(database.mangaTagRelationshipTables).get();
    //   expect(data.length, equals(0));
    // }
  });
}
