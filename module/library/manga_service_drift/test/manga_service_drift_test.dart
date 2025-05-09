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

  test('manga can be synced', () async {
    final mangas = [
      const MangaDrift(
        title: 'title',
        author: 'author',
        coverUrl: 'coverUrl',
        status: 'status',
        description: 'description',
        webUrl: 'webUrl',
        source: 'source',
      ),
    ];

    final result = await syncMangasDao.sync(mangas);

    expect(result.length, equals(1));
  });
}
