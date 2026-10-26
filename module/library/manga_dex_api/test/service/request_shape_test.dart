// Pins the HTTP request that every generated retrofit service builds today,
// so the codegen toolchain bump in #198 cannot silently change the wire
// format (method, path, query keys, headers) that MangaDex receives.
//
// Each test drives the real generated service through a capturing
// HttpClientAdapter that records the fully composed RequestOptions and then
// aborts the request, so no response body is needed.
//
// Run from `module/library/manga_dex_api`:
//   flutter test test/service/request_shape_test.dart

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

/// Records the [RequestOptions] dio composed for the last call and then
/// aborts the request with a [StateError], which dio surfaces as a
/// [DioException] — no network, no response body.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    throw StateError('captured');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _CapturingAdapter adapter;

  setUp(() {
    adapter = _CapturingAdapter();
  });

  /// Wires a fresh [Dio] to the capturing adapter.
  Dio dioFor() => Dio()..httpClientAdapter = adapter;

  /// Runs [call] (which always fails), then returns what the generated
  /// service put on the wire.
  Future<RequestOptions> capture(Future<Object?> call) async {
    await expectLater(call, throwsA(isA<DioException>()));
    final options = adapter.captured;
    expect(options, isNotNull, reason: 'the service never reached dio');
    return options!;
  }

  test('MangaService.search: nulls dropped, list and map params keep keys',
      () async {
    final service = MangaService(dioFor());

    final captured = await capture(
      service.search(
        title: 'x',
        limit: 10,
        authors: ['a1', 'a2'],
        orders: {'createdAt': 'desc'},
      ),
    );

    expect(captured.method, 'GET');
    expect(captured.baseUrl, 'https://api.mangadex.org');
    expect(captured.path, '/manga');
    expect(captured.queryParameters, {
      'title': 'x',
      'limit': 10,
      'authors[]': ['a1', 'a2'],
      'order': {'createdAt': 'desc'},
    });
    expect(captured.headers['Accept'], 'application/json');
    expect(captured.contentType, contains('application/json'));
  });

  test('MangaService.tags: no query parameters', () async {
    final service = MangaService(dioFor());

    final captured = await capture(service.tags());

    expect(captured.method, 'GET');
    expect(captured.baseUrl, 'https://api.mangadex.org');
    expect(captured.path, '/manga/tag');
    expect(captured.queryParameters, <String, dynamic>{});
  });

  test('MangaService.detail: id in the path, includes[] as a list', () async {
    final service = MangaService(dioFor());

    final captured =
        await capture(service.detail(id: 'm1', includes: ['author']));

    expect(captured.method, 'GET');
    expect(captured.path, '/manga/m1');
    expect(captured.queryParameters, {
      'includes[]': ['author'],
    });
  });

  test('MangaService.feed: id in the path, order map flattened by key',
      () async {
    final service = MangaService(dioFor());

    final captured = await capture(
      service.feed(id: 'm1', limit: 5, orders: {'chapter': 'asc'}),
    );

    expect(captured.method, 'GET');
    expect(captured.path, '/manga/m1/feed');
    expect(captured.queryParameters, {
      'limit': 5,
      'order': {'chapter': 'asc'},
    });
  });

  test('ChapterService.search: mangaId maps to manga, ids[] as a list',
      () async {
    final service = ChapterService(dioFor());

    final captured = await capture(service.search(mangaId: 'm1', ids: ['c1']));

    expect(captured.method, 'GET');
    expect(captured.baseUrl, 'https://api.mangadex.org');
    expect(captured.path, '/chapter');
    expect(captured.queryParameters, {
      'manga': 'm1',
      'ids[]': ['c1'],
    });
  });

  test('AuthorService.detail: id in the path, includes[] as a list', () async {
    final service = AuthorService(dioFor());

    final captured =
        await capture(service.detail(id: 'a1', includes: ['manga']));

    expect(captured.method, 'GET');
    expect(captured.path, '/author/a1');
    expect(captured.queryParameters, {
      'includes[]': ['manga'],
    });
  });

  test('CoverArtService.detail: id in the path, includes[] as a list',
      () async {
    final service = CoverArtService(dioFor());

    final captured =
        await capture(service.detail(id: 'cv1', includes: ['manga']));

    expect(captured.method, 'GET');
    expect(captured.path, '/cover/cv1');
    expect(captured.queryParameters, {
      'includes[]': ['manga'],
    });
  });

  test('AtHomeService.url: id in the path, no query parameters', () async {
    final service = AtHomeService(dioFor());

    final captured = await capture(service.url('c1'));

    expect(captured.method, 'GET');
    expect(captured.baseUrl, 'https://api.mangadex.org');
    expect(captured.path, '/at-home/server/c1');
    expect(captured.queryParameters, <String, dynamic>{});
  });
}
