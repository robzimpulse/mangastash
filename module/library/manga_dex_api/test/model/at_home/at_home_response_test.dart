import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/src/model/at_home/at_home_chapter.dart';
import 'package:manga_dex_api/src/model/at_home/at_home_response.dart';
import 'package:manga_dex_api/src/exception/at_home_server_exception.dart';

void main() {
  group('AtHomeResponse guard', () {
    test('null baseUrl + chapter hash → throws AtHomeServerException', () {
      expect(
        () => AtHomeResponse(
          'ok',
          null,
          AtHomeChapter('x', ['page1'], ['s1']),
        ),
        throwsA(isA<AtHomeServerException>()),
      );
    });

    test('empty baseUrl + chapter hash → throws AtHomeServerException', () {
      expect(
        () => AtHomeResponse(
          'ok',
          '',
          AtHomeChapter('x', ['page1'], ['s1']),
        ),
        throwsA(isA<AtHomeServerException>()),
      );
    });

    test('null baseUrl + no chapter data → empty lists, no throw', () {
      final response = AtHomeResponse('ok', null, null);
      expect(response.images, isEmpty);
      expect(response.imagesDataSaver, isEmpty);
    });
  });
}
