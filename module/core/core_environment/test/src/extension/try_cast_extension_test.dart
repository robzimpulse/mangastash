import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DistinctList Extension', () {
    test('distinct removes duplicates from list', () {
      final list = [1, 2, 2, 3, 1, 4];
      expect(list.distinct(), equals([1, 2, 3, 4]));
    });

    test('distinct handles empty list', () {
      final list = <int>[];
      expect(list.distinct(), isEmpty);
    });
  });

  group('NullableGeneric Extension', () {
    test('or returns original value if not null', () {
      const String value = 'original';
      expect(value.or('replace'), equals('original'));
    });

    test('or returns replacement value if null', () {
      const String? value = null;
      expect(value.or('replace'), equals('replace'));
    });

    test('orNull returns original value if not null', () {
      const String value = 'original';
      expect(value.orNull('replace'), equals('original'));
    });

    test('orNull returns replacement value if null', () {
      const String? value = null;
      expect(value.orNull('replace'), equals('replace'));
      
      const String? nullReplacement = null;
      expect(value.orNull(nullReplacement), isNull);
    });

    test('let applies function if not null', () {
      const String value = 'test';
      final result = value.let((e) => e.toUpperCase());
      expect(result, equals('TEST'));
    });

    test('let returns null without applying function if null', () {
      const String? value = null;
      bool called = false;
      final result = value.let((e) {
        called = true;
        return e.toUpperCase();
      });
      
      expect(result, isNull);
      expect(called, isFalse);
    });

    test('castOrNull safely casts', () {
      const String value = 'string';
      expect(value.castOrNull<String>(), equals('string'));
      
      const int number = 123;
      expect(number.castOrNull<String>(), isNull);
    });

    test('castOrFallback casts or returns fallback', () {
      const String value = 'string';
      expect(value.castOrFallback<String>('fallback'), equals('string'));
      
      const int number = 123;
      expect(number.castOrFallback<String>('fallback'), equals('fallback'));
    });
  });
}
