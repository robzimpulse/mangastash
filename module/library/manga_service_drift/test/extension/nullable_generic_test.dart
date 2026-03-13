import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/extension/nullable_generic.dart';

void main() {
  group('NullableGeneric', () {
    test('or', () {
      String? val;
      expect(val.or('fallback'), 'fallback');
      val = 'abc';
      expect(val.or('fallback'), 'abc');
    });

    test('orNull', () {
      String? val;
      expect(val.orNull('fallback'), 'fallback');
      val = 'abc';
      expect(val.orNull('fallback'), 'abc');
    });

    test('let', () {
      String? val;
      expect(val.let((s) => s.length), isNull);
      val = 'abc';
      expect(val.let((s) => s.length), 3);
    });

    test('castOrNull', () {
      Object? val = 123;
      expect(val.castOrNull<int>(), 123);
      expect(val.castOrNull<String>(), isNull);
    });

    test('castOrFallback', () {
      Object? val = 123;
      expect(val.castOrFallback<int>(0), 123);
      expect(val.castOrFallback<String>('fb'), 'fb');
    });
  });
}
