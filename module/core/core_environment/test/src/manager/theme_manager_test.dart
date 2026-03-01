import 'package:core_environment/src/manager/theme_manager.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSharedPreferencesAsync extends Mock implements SharedPreferencesAsync {}

void main() {
  group('ThemeManager', () {
    late MockSharedPreferencesAsync mockStorage;

    setUp(() {
      mockStorage = MockSharedPreferencesAsync();
    });

    test('create initializes with light theme when storage is empty', () async {
      when(() => mockStorage.getBool('is_dark_mode')).thenAnswer((_) async => null);

      final manager = await ThemeManager.create(storage: mockStorage);

      expect(manager.themeDataStream.value.brightness, equals(Brightness.light));
      verify(() => mockStorage.getBool('is_dark_mode')).called(1);
    });

    test('create initializes with dark theme when storage has true', () async {
      when(() => mockStorage.getBool('is_dark_mode')).thenAnswer((_) async => true);

      final manager = await ThemeManager.create(storage: mockStorage);

      expect(manager.themeDataStream.value.brightness, equals(Brightness.dark));
    });

    test('create initializes with light theme when storage has false', () async {
      when(() => mockStorage.getBool('is_dark_mode')).thenAnswer((_) async => false);

      final manager = await ThemeManager.create(storage: mockStorage);

      expect(manager.themeDataStream.value.brightness, equals(Brightness.light));
    });

    test('updateTheme updates storage and stream', () async {
      when(() => mockStorage.getBool('is_dark_mode')).thenAnswer((_) async => false);
      when(() => mockStorage.setBool('is_dark_mode', true)).thenAnswer((_) async {});

      final manager = await ThemeManager.create(storage: mockStorage);
      
      // Update to dark
      await manager.updateTheme(theme: ThemeData.dark());

      verify(() => mockStorage.setBool('is_dark_mode', true)).called(1);
      expect(manager.themeDataStream.value.brightness, equals(Brightness.dark));
      
      // Update to light
      when(() => mockStorage.setBool('is_dark_mode', false)).thenAnswer((_) async {});
      await manager.updateTheme(theme: ThemeData.light());

      verify(() => mockStorage.setBool('is_dark_mode', false)).called(1);
      expect(manager.themeDataStream.value.brightness, equals(Brightness.light));
    });
  });
}
