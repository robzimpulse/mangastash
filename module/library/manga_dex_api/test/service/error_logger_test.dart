// Pins the retrofit#862 contract: when a response body fails `fromJson`, the
// generated service must hand the original error to the `ParseErrorLogger`
// and rethrow it unchanged. The codegen bump in #198 moves retrofit to
// 4.10.0, whose `ParseErrorLogger.logError` gained an optional
// `{Response? response}`; this logger implements that 4-argument signature,
// which also compiles against 4.9.0's 3-argument version (an override may
// add optional parameters).
//
// Run from `module/library/manga_dex_api`:
//   flutter test test/service/error_logger_test.dart

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:retrofit/error_logger.dart';

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

/// Records what the generated service reported to retrofit's parse logger.
class _RecordingLogger implements ParseErrorLogger {
  final List<Object> errors = [];
  final List<RequestOptions> options = [];
  final List<Response<dynamic>?> responses = [];

  @override
  void logError(
    Object error,
    StackTrace stackTrace,
    RequestOptions options, {
    Response<dynamic>? response,
  }) {
    errors.add(error);
    this.options.add(options);
    responses.add(response);
  }
}

void main() {
  test(
    'a body that fails fromJson reaches ParseErrorLogger and is rethrown',
    () async {
      final dio = Dio();
      dio.httpClientAdapter = _FixedJsonAdapter(
        // `hash` is a number, but AtHomeChapter.hash is a String.
        '{"result":"ok","baseUrl":"https://x","chapter":{"hash":1}}',
      );
      final logger = _RecordingLogger();
      final service = AtHomeService(dio, errorLogger: logger);

      await expectLater(service.url('c1'), throwsA(isA<TypeError>()));

      expect(logger.errors, hasLength(1));
      expect(logger.errors.single, isA<TypeError>());
      expect(logger.options.single.path, '/at-home/server/c1');
    },
  );
}
