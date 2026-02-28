import 'dart:ui';
import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocaleExtension', () {
    test('country returns correct Country enum', () {
      const locale = Locale('en', 'US');
      expect(locale.country, equals(Country.unitedStates));
    });

    test('country returns null if countryCode is null', () {
      const locale = Locale('en');
      expect(locale.country, isNull);
    });

    test('language returns correct Language enum', () {
      const locale = Locale('en', 'US');
      expect(locale.language, equals(Language.english));
    });
  });
}
