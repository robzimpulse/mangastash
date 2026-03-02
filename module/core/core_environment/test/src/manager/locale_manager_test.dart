import 'dart:ui';

import 'package:core_environment/src/manager/locale_manager.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSharedPreferencesAsync extends Mock implements SharedPreferencesAsync {}

void main() {
  group('LocaleManager', () {
    late MockSharedPreferencesAsync mockStorage;

    setUp(() {
      mockStorage = MockSharedPreferencesAsync();
    });

    test('create initializes from storage', () async {
      when(() => mockStorage.getString('locale')).thenAnswer((_) async => 'id_ID');

      final manager = await LocaleManager.create(storage: mockStorage);

      expect(manager.localeDataStream.value, equals(const Locale('id', 'ID')));
    });

    test('create initializes from storage with only language code', () async {
      when(() => mockStorage.getString('locale')).thenAnswer((_) async => 'en');

      final manager = await LocaleManager.create(storage: mockStorage);

      expect(manager.localeDataStream.value, equals(const Locale('en')));
    });

    test('updateLocale updates storage and stream', () async {
      when(() => mockStorage.getString('locale')).thenAnswer((_) async => 'en');
      when(() => mockStorage.setString('locale', 'id_ID')).thenAnswer((_) async {});

      final manager = await LocaleManager.create(storage: mockStorage);
      
      manager.updateLocale(locale: const Locale('id', 'ID'));

      verify(() => mockStorage.setString('locale', 'id_ID')).called(1);
      expect(manager.localeDataStream.value, equals(const Locale('id', 'ID')));
    });

    test('updateLocale handles null country code', () async {
      when(() => mockStorage.getString('locale')).thenAnswer((_) async => 'en');
      when(() => mockStorage.setString('locale', 'id')).thenAnswer((_) async {});

      final manager = await LocaleManager.create(storage: mockStorage);
      
      manager.updateLocale(locale: const Locale('id'));

      verify(() => mockStorage.setString('locale', 'id')).called(1);
      expect(manager.localeDataStream.value, equals(const Locale('id')));
    });
  });
}
