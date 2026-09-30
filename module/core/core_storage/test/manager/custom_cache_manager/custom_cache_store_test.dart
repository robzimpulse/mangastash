import 'package:core_storage/src/manager/custom_cache_manager/custom_cache_manager.dart';
import 'package:core_storage/src/manager/custom_cache_manager/custom_cache_store.dart';
import 'package:fake_async/fake_async.dart';
import 'package:file/file.dart' show File, FileSystemException;
import 'package:file/memory.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCacheInfoRepository extends Mock implements CacheInfoRepository {}

class _MockFile extends Mock implements File {}

class _MockFileSystem extends Mock implements FileSystem {}

/// Delegates flutter_cache_manager's [FileSystem] abstraction to an
/// in-memory [MemoryFileSystem] so tests never touch real disk.
class _MemoryFileSystem implements FileSystem {
  _MemoryFileSystem(this.fs);

  final MemoryFileSystem fs;

  @override
  Future<File> createFile(String name) async => fs.file(name);
}

class _FakeFileService implements FileService {
  @override
  int concurrentFetches = 10;

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }
}

class _FakeConfig implements Config {
  _FakeConfig({required this.repo, required this.fileSystem});

  @override
  final String cacheKey = 'test';

  @override
  final CacheInfoRepository repo;

  @override
  final FileSystem fileSystem;

  @override
  final int maxNrOfCacheObjects = 200;

  @override
  final Duration stalePeriod = const Duration(days: 30);

  @override
  final FileService fileService = _FakeFileService();
}

CacheObject _object({required int id, required String key}) {
  return CacheObject(
    'https://example.com/$key',
    key: key,
    relativePath: '$key.html',
    validTill: DateTime.now().add(const Duration(days: 7)),
    id: id,
    length: 12,
  );
}

void main() {
  late _MockCacheInfoRepository repo;
  late MemoryFileSystem fs;
  late _MemoryFileSystem fileSystem;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(
      CacheObject(
        '',
        relativePath: '',
        validTill: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  });

  setUp(() {
    repo = _MockCacheInfoRepository();
    fs = MemoryFileSystem();
    fileSystem = _MemoryFileSystem(fs);
    when(() => repo.open()).thenAnswer((_) async => true);
    when(() => repo.close()).thenAnswer((_) async => true);
    when(() => repo.deleteAll(any())).thenAnswer((_) async => 0);
  });

  group('CustomCacheStore', () {
    test('removeCachedFile deletes the file and index row', () async {
      final store = CustomCacheStore(_FakeConfig(repo: repo, fileSystem: fileSystem));
      final object = _object(id: 1, key: 'a');
      final file = fs.file('a.html')
        ..createSync(recursive: true)
        ..writeAsStringSync('data');

      await store.removeCachedFile(object);

      expect(file.existsSync(), isFalse);
      verify(() => repo.deleteAll([1])).called(1);
    });

    test('emptyCache deletes every file and index row', () async {
      final store = CustomCacheStore(_FakeConfig(repo: repo, fileSystem: fileSystem));
      final objects = [_object(id: 1, key: 'a'), _object(id: 2, key: 'b')];
      final files = [
        for (final object in objects)
          fs.file('${object.key}.html')
            ..createSync(recursive: true)
            ..writeAsStringSync('data'),
      ];
      when(() => repo.getAllObjects()).thenAnswer((_) async => objects);

      await store.emptyCache();

      for (final file in files) {
        expect(file.existsSync(), isFalse);
      }
      verify(() => repo.deleteAll([1, 2])).called(1);
    });

    test('scheduled cleanup deletes files of over-capacity objects', () {
      fakeAsync((async) {
        final object = _object(id: 1, key: 'a');
        final file = fs.file('a.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('data');
        when(() => repo.get(any())).thenAnswer((_) async => null);
        when(
          () => repo.getObjectsOverCapacity(any()),
        ).thenAnswer((_) async => [object]);
        when(
          () => repo.getOldObjects(any()),
        ).thenAnswer((_) async => <CacheObject>[]);

        final store = CustomCacheStore(_FakeConfig(repo: repo, fileSystem: fileSystem))
          ..cleanupRunMinInterval = Duration.zero;

        store.retrieveCacheData('a');
        async.flushTimers();

        expect(file.existsSync(), isFalse);
        verify(() => repo.deleteAll([1])).called(1);
      });
    });

    test('scheduled cleanup deletes files of stale objects', () {
      fakeAsync((async) {
        final object = _object(id: 1, key: 'a');
        final file = fs.file('a.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('data');
        when(() => repo.get(any())).thenAnswer((_) async => null);
        when(
          () => repo.getObjectsOverCapacity(any()),
        ).thenAnswer((_) async => <CacheObject>[]);
        when(
          () => repo.getOldObjects(any()),
        ).thenAnswer((_) async => [object]);

        final store = CustomCacheStore(_FakeConfig(repo: repo, fileSystem: fileSystem))
          ..cleanupRunMinInterval = Duration.zero;

        store.retrieveCacheData('a');
        async.flushTimers();

        expect(file.existsSync(), isFalse);
        verify(() => repo.deleteAll([1])).called(1);
      });
    });

    test('rescueEvictedFile runs before the file is deleted', () async {
      final events = <String>[];
      Future<void> rescue(CacheObject object, File file) async {
        events.add('rescue:${object.key}');
      }

      final store = CustomCacheStore(
        _FakeConfig(repo: repo, fileSystem: fileSystem),
        rescueEvictedFile: rescue,
      );
      final object = _object(id: 1, key: 'a');
      final file = fs.file('a.html')
        ..createSync(recursive: true)
        ..writeAsStringSync('data');

      await store.removeCachedFile(object);

      expect(events, ['rescue:a']);
      expect(file.existsSync(), isFalse);
      verify(() => repo.deleteAll([1])).called(1);
    });

    test(
      'a rescue failure is logged and the file is still deleted',
      () async {
        Future<void> rescue(CacheObject object, File file) async {
          throw Exception('rescue boom');
        }

        final store = CustomCacheStore(
          _FakeConfig(repo: repo, fileSystem: fileSystem),
          rescueEvictedFile: rescue,
        );
        final object = _object(id: 1, key: 'a');
        fs.file('a.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('data');

        await store.removeCachedFile(object);

        expect(fs.file('a.html').existsSync(), isFalse);
        verify(() => repo.deleteAll([1])).called(1);
      },
    );

    test(
      'a FileSystemException during deletion is swallowed and rows are still removed',
      () async {
        final mockFile = _MockFile();
        final mockFs = _MockFileSystem();
        final object = _object(id: 1, key: 'a');
        when(
          () => mockFs.createFile(any()),
        ).thenAnswer((_) async => mockFile);
        when(() => mockFile.existsSync()).thenReturn(true);
        when(() => mockFile.delete()).thenThrow(const FileSystemException('boom'));

        final store = CustomCacheStore(_FakeConfig(repo: repo, fileSystem: mockFs));

        await store.removeCachedFile(object);

        verify(() => mockFile.delete()).called(1);
        verify(() => repo.deleteAll([1])).called(1);

        await store.dispose();
      },
    );
  });

  group('CustomCacheManager', () {
    test('threads rescueEvictedFile to the store', () {
      fakeAsync((async) {
        final object = _object(id: 1, key: 'a');
        fs.file('a.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('data');
        final rescued = <String>[];
        when(() => repo.get(any())).thenAnswer((_) async => object);
        when(() => repo.updateOrInsert(any())).thenAnswer((_) async => object);
        when(
          () => repo.getObjectsOverCapacity(any()),
        ).thenAnswer((_) async => <CacheObject>[]);
        when(
          () => repo.getOldObjects(any()),
        ).thenAnswer((_) async => <CacheObject>[]);

        final manager = CustomCacheManager(
          _FakeConfig(repo: repo, fileSystem: fileSystem),
          rescueEvictedFile: (object, file) async {
            rescued.add(object.key);
          },
        );

        manager.removeFile('a');
        async.flushTimers();

        expect(rescued, ['a']);
        expect(fs.file('a.html').existsSync(), isFalse);
        verify(() => repo.deleteAll([1])).called(1);
      });
    });
  });
}
