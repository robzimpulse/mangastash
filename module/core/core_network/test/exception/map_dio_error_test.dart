import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapDioError', () {
    test('429 + integer Retry-After → RateLimitException', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 429,
          headers: Headers.fromMap({'Retry-After': ['5']}),
        ),
      );
      final result = mapDioError(dio);
      expect(result, isA<RateLimitException>());
      final rate = result as RateLimitException;
      expect(rate.retryAfter, equals(const Duration(seconds: 5)));
    });

    test('429 + HTTP-date Retry-After → retryAfter null', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 429,
          headers: Headers.fromMap({
            'Retry-After': ['Wed, 21 Oct 2026 07:28:00 GMT']
          }),
        ),
      );
      final result = mapDioError(dio);
      expect(result, isA<RateLimitException>());
      final rate = result as RateLimitException;
      expect(rate.retryAfter, isNull);
    });

    test('500 → HttpStatusException', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
        ),
      );
      final result = mapDioError(dio);
      expect(result, isA<HttpStatusException>());
      expect((result as HttpStatusException).statusCode, equals(500));
    });

    test('null status in response → NetworkException', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: null,
        ),
        error: 'timeout',
      );
      final result = mapDioError(dio);
      expect(result, isA<NetworkException>());
    });

    test('cancellation passes through unchanged', () {
      final dio = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.cancel,
      );
      final result = mapDioError(dio);
      expect(identical(result, dio), isTrue);
    });

    test('non-Dio Exception passes through unchanged', () {
      final exc = Exception('plain');
      final result = mapDioError(exc);
      expect(identical(result, exc), isTrue);
    });

    test('non-Exception wrapped', () {
      final result = mapDioError('raw string');
      expect(result, isA<Exception>());
      expect(result.toString(), contains('raw string'));
    });
  });
}
