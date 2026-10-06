// Unit tests for ImagesCacheManager's app-database lookup (issue #131):
// an empty database result is a clean miss (null), not an exception thrown
// by `results.first` — the old exception-as-control-flow pattern logged a
// full error + stack trace on every cache miss before falling to network.
//
// Run with: fvm flutter test test/manager/storage_manager/images_cache_manager_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_storage/src/manager/storage_manager/file_service/custom_file_service.dart';
import 'package:core_storage/src/manager/storage_manager/images_cache_manager.dart';
import 'package:file/file.dart' show File;
import 'package:file/memory.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:mocktail/mocktail.dart';

class _MockFileDao extends Mock implements FileDao {}

class _MockFileService extends Mock implements CustomFileService {}

class _MockLogBox extends Mock implements LogBox {}

class _MockFile extends Mock implements File {}

class _MockCacheInfoRepository extends Mock implements CacheInfoRepository {}

/// Delegates flutter_cache_manager's [FileSystem] to an in-memory
/// implementation so the manager never touches the platform temp
/// directory (see the `fileSystem` parameter on [ImagesCacheManager]).
class _MemoryFileSystem implements FileSystem {
  final MemoryFileSystem fs = MemoryFileSystem();

  @override
  Future<File> createFile(String name) async => fs.file(name);
}

void main() {
  const url = 'https://uploads.mangadex.org/a.jpg';

  late _MockFileDao fileDao;
  late _MockCacheInfoRepository repo;
  late ImagesCacheManager manager;

  setUp(() {
    fileDao = _MockFileDao();
    // CustomCacheStore opens the repository eagerly in its constructor;
    // a stubbed open keeps that off the platform channels.
    repo = _MockCacheInfoRepository();
    when(() => repo.open()).thenAnswer((_) async => true);
    when(() => repo.close()).thenAnswer((_) async => true);
    manager = ImagesCacheManager(
      fileService: _MockFileService(),
      fileDao: fileDao,
      logBox: _MockLogBox(),
      fileSystem: _MemoryFileSystem(),
      repo: repo,
    );
  });

  group('getFromDatabase (#131)', () {
    test('returns null on a clean miss instead of throwing', () async {
      // No persisted row for the URL: the lookup must resolve to null so
      // callers can fall back to the cache without an error log.
      when(() => fileDao.search(webUrls: [url])).thenAnswer((_) async => []);

      final result = await manager.getFromDatabase(url: url);

      expect(result, isNull);
    });

    test('returns the persisted file on a hit', () async {
      final row = FileDrift(
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        id: 'file-1',
        webUrl: url,
        relativePath: 'a.jpg',
      );
      final file = _MockFile();
      when(() => fileDao.search(webUrls: [url])).thenAnswer((_) async => [row]);
      when(() => fileDao.file(row)).thenAnswer((_) async => file);

      final result = await manager.getFromDatabase(url: url);

      expect(result, same(file));
    });
  });
}
