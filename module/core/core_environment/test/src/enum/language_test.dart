import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Language Enum', () {
    test('fromCode returns correct language', () {
      expect(Language.fromCode('en'), equals(Language.english));
      expect(Language.fromCode('id'), equals(Language.indonesia));
    });

    test('fromCode returns default (english) for unknown code', () {
      expect(Language.fromCode('UNKNOWN'), equals(Language.english));
      expect(Language.fromCode(null), equals(Language.english));
    });

    test('fromName returns correct language', () {
      expect(Language.fromName('English'), equals(Language.english));
      expect(Language.fromName('Indonesian'), equals(Language.indonesia));
    });

    test('fromName returns default (english) for unknown name', () {
      expect(Language.fromName('Unknown Language'), equals(Language.english));
      expect(Language.fromName(null), equals(Language.english));
    });

    test('flag returns CountryFlag widget', () {
      final flag = Language.english.flag();
      expect(flag, isNotNull);
    });

    test('sorted returns list ordered by name', () {
      final sortedList = Language.sorted;
      expect(sortedList, isNotEmpty);
      
      for (var i = 0; i < sortedList.length - 1; i++) {
        expect(
          sortedList[i].name.compareTo(sortedList[i + 1].name) <= 0,
          isTrue,
        );
      }
    });
  });
}
