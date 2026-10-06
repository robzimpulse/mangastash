import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

/// Always serves the same JSON body with a 200 — drives the real retrofit
/// service through dio's response path without any network.
class _FixedJsonAdapter implements HttpClientAdapter {
  _FixedJsonAdapter(this.body);

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = Uint8List.fromList(body.codeUnits);
    return ResponseBody(
      Stream.value(bytes),
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'null baseUrl payload surfaces AtHomeServerException from the service, '
    'not a re-wrapped DioException (review on #181)',
    () async {
      final dio = Dio();
      dio.httpClientAdapter = _FixedJsonAdapter(
        '{"result":"ok","baseUrl":null,'
        '"chapter":{"hash":"abc","data":["1.png"],"dataSaver":["1.webp"]}}',
      );
      final service = AtHomeService(dio);

      // The guard throws inside AtHomeResponse's constructor, which runs in
      // the generated service method AFTER `await _dio.fetch(...)` — outside
      // dio's assureDioException normalization. If that ever changes, this
      // test fails and the guard must move up to AtHomeRepository.url.
      await expectLater(
        service.url('chapter-id'),
        throwsA(isA<AtHomeServerException>()),
      );
    },
  );
}
