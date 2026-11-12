// Unit tests for ImagesCacheManager's app-database lookup (issue #131):
// an empty database result is a clean miss (null), not an exception thrown
// by `results.first` — the old exception-as-control-flow pattern logged a
// full error + stack trace on every cache miss before falling to network.
//
// Also pins issue #207: the image cache's own config guards its file service
// against HTML bodies (bot challenge / Cloudflare pages), whatever service
// the registrar hands it.
//
// Run with: fvm flutter test test/manager/storage_manager/images_cache_manager_test.dart
import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart'
    show
        Dio,
        HeadlessWebviewUseCase,
        HttpClientAdapter,
        RequestOptions,
        ResponseBody;
import 'package:core_storage/src/manager/storage_manager/file_service/custom_file_service.dart';
import 'package:core_storage/src/manager/storage_manager/file_service/image_base64_get_response.dart';
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

class _MockHeadlessWebviewUseCase extends Mock
    implements HeadlessWebviewUseCase {}

/// Serves every request as a `200 text/html` page, like a bot challenge.
class _HtmlAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody(
      Stream.value(Uint8List.fromList('<html></html>'.codeUnits)),
      200,
      headers: {
        'content-type': ['text/html; charset=UTF-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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
    final fileService = _MockFileService();
    when(() => fileService.withRejectHtml()).thenReturn(fileService);
    manager = ImagesCacheManager(
      fileService: fileService,
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

  group('HTML guard (#207)', () {
    test('config falls back to webview for text/html even when the '
        'given file service does not reject HTML', () async {
      final dio = Dio()..httpClientAdapter = _HtmlAdapter();
      final webview = _MockHeadlessWebviewUseCase();
      when(
        () => webview.image(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async =>
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );

      final config = ImagesCacheManager.buildConfig(
        fileService: CustomFileService(
          dio: () => dio,
          headlessWebviewUseCase: () => webview,
        ),
        fileSystem: _MemoryFileSystem(),
        repo: repo,
      );

      final response = await config.fileService.get(url);

      expect(response, isA<ImageBase64GetResponse>());
      verify(
        () => webview.image(url, headers: any(named: 'headers')),
      ).called(1);
    });
  });
}
