/// Unit tests for [CustomFileService].
///
/// Verifies that when [rejectHtml] is enabled, HTML responses (such as POWBlock challenge pages
/// or Cloudflare walls) are rejected and fall back to [HeadlessWebviewUseCase.image],
/// while image responses, responses without content-type, and services with [rejectHtml] disabled
/// continue using Dio.
///
/// Usage:
/// Run via `fvm flutter test test/manager/storage_manager/file_service/custom_file_service_test.dart`.
import 'dart:async';
import 'dart:typed_data';

import 'package:core_network/core_network.dart';
import 'package:core_storage/src/manager/storage_manager/file_service/custom_file_service.dart';
import 'package:core_storage/src/manager/storage_manager/file_service/dio_get_response.dart';
import 'package:core_storage/src/manager/storage_manager/file_service/image_base64_get_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHeadlessWebviewUseCase extends Mock
    implements HeadlessWebviewUseCase {}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.headers});

  final Map<String, List<String>>? headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody(
      Stream.value(Uint8List.fromList([1, 2, 3])),
      200,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const testUrl = 'https://uploads.mangadex.org/covers/manga-1/cover.jpg';
  late _MockHeadlessWebviewUseCase webview;

  setUp(() {
    webview = _MockHeadlessWebviewUseCase();
    when(
      () => webview.image(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async =>
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );
  });

  test('rejectHtml: text/html falls back to webview', () async {
    final dio = Dio();
    dio.httpClientAdapter = _StubAdapter(
      headers: {
        'content-type': ['text/html; charset=UTF-8'],
      },
    );

    final service = CustomFileService(
      dio: () => dio,
      headlessWebviewUseCase: () => webview,
      rejectHtml: true,
    );

    final response = await service.get(testUrl);

    expect(response, isA<ImageBase64GetResponse>());
    verify(() => webview.image(testUrl, headers: any(named: 'headers'))).called(1);
  });

  test('rejectHtml: image/jpeg uses Dio', () async {
    final dio = Dio();
    dio.httpClientAdapter = _StubAdapter(
      headers: {
        'content-type': ['image/jpeg'],
      },
    );

    final service = CustomFileService(
      dio: () => dio,
      headlessWebviewUseCase: () => webview,
      rejectHtml: true,
    );

    final response = await service.get(testUrl);

    expect(response, isA<DioGetResponse>());
    verifyNever(() => webview.image(any(), headers: any(named: 'headers')));
  });

  test('rejectHtml: missing content-type uses Dio', () async {
    final dio = Dio();
    dio.httpClientAdapter = _StubAdapter(headers: null);

    final service = CustomFileService(
      dio: () => dio,
      headlessWebviewUseCase: () => webview,
      rejectHtml: true,
    );

    final response = await service.get(testUrl);

    expect(response, isA<DioGetResponse>());
    verifyNever(() => webview.image(any(), headers: any(named: 'headers')));
  });

  test('withRejectHtml: guarded copy falls back for text/html', () async {
    final dio = Dio();
    dio.httpClientAdapter = _StubAdapter(
      headers: {
        'content-type': ['text/html; charset=UTF-8'],
      },
    );

    final service = CustomFileService(
      dio: () => dio,
      headlessWebviewUseCase: () => webview,
    ).withRejectHtml();

    final response = await service.get(testUrl);

    expect(response, isA<ImageBase64GetResponse>());
    verify(
      () => webview.image(testUrl, headers: any(named: 'headers')),
    ).called(1);
  });

  test('default (rejectHtml false): text/html uses Dio', () async {
    final dio = Dio();
    dio.httpClientAdapter = _StubAdapter(
      headers: {
        'content-type': ['text/html; charset=UTF-8'],
      },
    );

    final service = CustomFileService(
      dio: () => dio,
      headlessWebviewUseCase: () => webview,
    );

    final response = await service.get(testUrl);

    expect(response, isA<DioGetResponse>());
    verifyNever(() => webview.image(any(), headers: any(named: 'headers')));
  });
}
