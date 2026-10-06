// Tests for mapNetworkError composition (issue #118, task 7): the MangaDex
// error envelope wins over the generic Dio mapping, non-Dio exceptions pass
// through untouched, and non-Exception inputs are wrapped.
//
// Run with: fvm flutter test test/extension/map_network_error_test.dart
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/extension/map_network_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

Map<String, dynamic> envelopeBody() => <String, dynamic>{
  'result': 'error',
  'errors': [
    <String, dynamic>{
      'id': 'rate-limited',
      'status': 429,
      'title': 'Rate limited',
      'detail': 'Slow down',
    },
  ],
};

DioException dioError({required int statusCode, dynamic data}) => DioException(
  requestOptions: RequestOptions(),
  response: Response(
    requestOptions: RequestOptions(),
    statusCode: statusCode,
    data: data,
  ),
);

void main() {
  test('a 429 with an envelope body decodes to MangadexServerException', () {
    final error = mapNetworkError(
      dioError(statusCode: 429, data: envelopeBody()),
    );

    expect(error, isA<MangadexServerException>());
  });

  test('a 429 without an envelope body maps to RateLimitException', () {
    final error = mapNetworkError(
      dioError(statusCode: 429, data: <String, dynamic>{'result': 'ok'}),
    );

    expect(error, isA<RateLimitException>());
  });

  test('a CloudflareChallengeException passes through identical', () {
    final original = CloudflareChallengeException('https://example.com');

    expect(mapNetworkError(original), same(original));
  });

  test('a string input is wrapped in an Exception', () {
    final error = mapNetworkError('boom');

    expect(error, isA<Exception>());
    expect(error.toString(), contains('boom'));
  });
}
