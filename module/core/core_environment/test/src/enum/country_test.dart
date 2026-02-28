import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Country Enum', () {
    test('fromCode returns correct country', () {
      expect(Country.fromCode('US'), equals(Country.unitedStates));
      expect(Country.fromCode('ID'), equals(Country.indonesia));
    });

    test('fromCode returns default (indonesia) for unknown code', () {
      expect(Country.fromCode('UNKNOWN'), equals(Country.indonesia));
    });

    test('fromName returns correct country', () {
      expect(Country.fromName('United States'), equals(Country.unitedStates));
      expect(Country.fromName('Indonesia'), equals(Country.indonesia));
    });

    test('fromName returns default (indonesia) for unknown name', () {
      expect(Country.fromName('Unknown Country'), equals(Country.indonesia));
    });

    test('flag returns CountryFlag widget', () {
      final flag = Country.indonesia.flag();
      expect(flag, isNotNull);
      // CountryFlag internally uses the country code
    });

    test('sorted returns list ordered by name', () {
      final sortedList = Country.sorted;
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
