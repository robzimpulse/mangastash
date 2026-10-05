import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RateLimitException carries 429 and retryAfter', () {
    final dio = DioException(
      requestOptions: RequestOptions(),
      response: Response(
        requestOptions: RequestOptions(),
        statusCode: 429,
      ),
    );
    final exc = RateLimitException(
      cause: dio,
      retryAfter: const Duration(seconds: 5),
    );
    expect(exc.statusCode, equals(429));
    expect(exc.retryAfter, equals(const Duration(seconds: 5)));
    expect(exc.toString(), contains('429'));
    expect(exc.toString(), contains('5'));
  });

  test('HttpStatusException carries status and snippet', () {
    final dio = DioException(
      requestOptions: RequestOptions(),
      response: Response(
        requestOptions: RequestOptions(),
        statusCode: 500,
      ),
    );
    final exc = HttpStatusException(
      statusCode: 500,
      cause: dio,
      bodySnippet: 'bad',
    );
    expect(exc.statusCode, equals(500));
    expect(exc.toString(), contains('500'));
  });

  test('NetworkException carries cause', () {
    final dio = DioException(requestOptions: RequestOptions());
    final exc = NetworkException(cause: dio);
    expect(exc.cause, same(dio));
    expect(exc.toString(), contains('NetworkException'));
  });
}
