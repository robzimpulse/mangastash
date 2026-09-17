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
    test(
      'removeCachedFile deletes the file and index row by default and emits no event',
      () async {
        final store = CustomCacheStore(_FakeConfig(repo: repo, fileSystem: fileSystem));
        final object = _object(id: 1, key: 'a');
        final file = fs.file('a.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('data');
        final events = <DeletedFileData>[];
        final subscription = store.deleteFileEvent.listen(events.add);

        await store.removeCachedFile(object);

        expect(file.existsSync(), isFalse);
        verify(() => repo.deleteAll([1])).called(1);
        expect(events, isEmpty);

        await subscription.cancel();
        await store.dispose();
      },
    );

    test(
      'emptyCache deletes every file and index row by default and emits no event',
      () async {
        final store = CustomCacheStore(_FakeConfig(repo: repo, fileSystem: fileSystem));
        final objects = [_object(id: 1, key: 'a'), _object(id: 2, key: 'b')];
        final files = [
          for (final object in objects)
            fs.file('${object.key}.html')
              ..createSync(recursive: true)
              ..writeAsStringSync('data'),
        ];
        when(() => repo.getAllObjects()).thenAnswer((_) async => objects);
        final events = <DeletedFileData>[];
        final subscription = store.deleteFileEvent.listen(events.add);

        await store.emptyCache();

        for (final file in files) {
          expect(file.existsSync(), isFalse);
        }
        verify(() => repo.deleteAll([1, 2])).called(1);
        expect(events, isEmpty);

        await subscription.cancel();
        await store.dispose();
      },
    );

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

    test(
      'when deleteFileOnEviction is false the file survives and the event fires',
      () async {
        final store = CustomCacheStore(
          _FakeConfig(repo: repo, fileSystem: fileSystem),
          deleteFileOnEviction: false,
        );
        final object = _object(id: 1, key: 'a');
        final file = fs.file('a.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('data');
        final events = <DeletedFileData>[];
        final subscription = store.deleteFileEvent.listen(events.add);

        await store.removeCachedFile(object);
        await Future<void>.delayed(Duration.zero);

        expect(file.existsSync(), isTrue);
        verify(() => repo.deleteAll([1])).called(1);
        expect(events, hasLength(1));
        final (eventObject, eventFile) = events.single;
        expect(eventObject.key, 'a');
        expect(eventFile.path, file.path);

        await subscription.cancel();
        await store.dispose();
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
        when(
          () => mockFile.delete(),
        ).thenThrow(const FileSystemException('boom'));

        final store = CustomCacheStore(
          _FakeConfig(repo: repo, fileSystem: mockFs),
        );

        await store.removeCachedFile(object);

        verify(() => mockFile.delete()).called(1);
        verify(() => repo.deleteAll([1])).called(1);

        await store.dispose();
      },
    );
  });

  group('CustomCacheManager', () {
    test('threads deleteFileOnEviction to the store', () {
      fakeAsync((async) {
        final object = _object(id: 1, key: 'a');
        fs.file('a.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('data');
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
          deleteFileOnEviction: false,
        );
        final events = <DeletedFileData>[];
        final subscription = manager.deleteFileEvent.listen(events.add);

        manager.removeFile('a');
        async.flushTimers();

        expect(events, hasLength(1));
        expect(fs.file('a.html').existsSync(), isTrue);
        verify(() => repo.deleteAll([1])).called(1);

        subscription.cancel();
      });
    });
  });
}
