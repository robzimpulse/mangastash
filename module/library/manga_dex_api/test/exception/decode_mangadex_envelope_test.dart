import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/src/exception/decode_mangadex_envelope.dart';
import 'package:manga_dex_api/src/exception/server_exception.dart';

void main() {
  group('decodeMangadexEnvelope', () {
    test('Map body with error envelope returns exception', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
          data: {
            'result': 'error',
            'errors': [
              {'id': 'test', 'status': 404, 'title': 'Not found', 'detail': ''}
            ],
          },
        ),
      );
      final result = decodeMangadexEnvelope(dio);
      expect(result, isNotNull);
      expect(result, isA<MangadexServerException>());
    });

    test('JSON-string body with error envelope returns exception', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
          data: '{"result":"error","errors":[{"id":"t","status":400}]}',
        ),
      );
      final result = decodeMangadexEnvelope(dio);
      expect(result, isNotNull);
    });

    test('non-error result returns null', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: {'result': 'ok'},
        ),
      );
      expect(decodeMangadexEnvelope(dio), isNull);
    });

    test('empty errors list returns null', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
          data: {'result': 'error', 'errors': []},
        ),
      );
      expect(decodeMangadexEnvelope(dio), isNull);
    });

    test('plain HTML body returns null', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
          data: '<html>error</html>',
        ),
      );
      expect(decodeMangadexEnvelope(dio), isNull);
    });

    test('non-Dio input returns null', () {
      expect(decodeMangadexEnvelope('not dio'), isNull);
    });

    test('DioException without response returns null', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        error: 'timeout',
      );
      expect(decodeMangadexEnvelope(dio), isNull);
    });
  });
}
