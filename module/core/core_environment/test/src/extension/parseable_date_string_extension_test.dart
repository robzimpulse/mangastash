import 'dart:convert';
import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:file/file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeLogBox extends Mock implements LogBox {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockFileInfo extends Mock implements FileInfo {}

class MockFile extends Mock implements File {}

class FakeStorage extends Mock implements Storage {}

class FakeEncoding extends Fake implements Encoding {}
class FakeEntryModel extends Fake implements EntryModel {}

void main() {
  group('ParseableDateStringExtension', () {
    late FakeLogBox fakeLogBox;
    late MockConverterCacheManager mockCacheManager;
    late FakeStorage mockStorage;

    setUp(() {
      fakeLogBox = FakeLogBox();
      mockStorage = FakeStorage();
      mockCacheManager = MockConverterCacheManager();

      registerFallbackValue(Uint8List(0));
      registerFallbackValue(FakeEncoding());
      registerFallbackValue(FakeEntryModel());

      when(
        () => mockCacheManager.getFileFromCache(any()),
      ).thenAnswer((_) async => null);
      
      when(() => fakeLogBox.storage).thenReturn(mockStorage);
      when(() => fakeLogBox.routes).thenReturn({});
      // Add empty action to prevent UnimplementedError
      when(() => mockStorage.add(log: any(named: 'log'))).thenAnswer((_) {});
    });

    test('asDateTime handles empty string', () async {
      final date = await ''.asDateTime(logbox: fakeLogBox);
      expect(date, isNull);

      final captured = verify(
        () => mockStorage.add(log: captureAny(named: 'log')),
      ).captured;
      expect(captured.last, isA<LogEntryModel>());
      expect((captured.last as LogEntryModel).message, contains('Failed Parsing Date'));
    });

    test('asDateTime parses ISO 8601 strings', () async {
      const isoString = '2023-10-25T14:30:00.000Z';
      final date = await isoString.asDateTime(logbox: fakeLogBox);

      expect(date, isNotNull);
      expect(date!.year, equals(2023));
      expect(date.month, equals(10));
      expect(date.day, equals(25));
    });

    test('asDateTime parses exact custom formats', () async {
      const customString = 'October 25 2023';
      final date = await customString.asDateTime(logbox: fakeLogBox);

      expect(date, isNotNull);
      final localDate = date!.toLocal();
      expect(localDate.year, equals(2023));
      expect(localDate.month, equals(10));
      expect(localDate.day, equals(25));
    });

    test('asDateTime parses slash format', () async {
      const customString = '10/25/2023';
      final date = await customString.asDateTime(logbox: fakeLogBox);

      expect(date, isNotNull);
      final localDate = date!.toLocal();
      expect(localDate.year, equals(2023));
      expect(localDate.month, equals(10));
      expect(localDate.day, equals(25));
    });

    test('asDateTime parses relative dates - yesterday', () async {
      final date = await 'yesterday'.asDateTime(logbox: fakeLogBox);

      expect(date, isNotNull);

      final expected = DateTime.now().subtract(const Duration(days: 1));
      expect(date!.day, equals(expected.day));
      expect(date.month, equals(expected.month));
      expect(date.year, equals(expected.year));
    });

    test('asDateTime parses relative dates - today', () async {
      final date = await 'today'.asDateTime(logbox: fakeLogBox);

      expect(date, isNotNull);

      final expected = DateTime.now();
      expect(date!.day, equals(expected.day));
    });

    test('asDateTime parses relative dates with ago syntax', () async {
      final now = DateTime.now();

      final secDate = await '5 sec ago'.asDateTime(logbox: fakeLogBox);
      expect(secDate, isNotNull);
      // Give 1 second tolerance for test execution time
      expect(now.difference(secDate!).inSeconds, inInclusiveRange(4, 6));

      final minDate = await '10 min ago'.asDateTime(logbox: fakeLogBox);
      expect(minDate, isNotNull);
      expect(now.difference(minDate!).inMinutes, inInclusiveRange(9, 11));

      final hourDate = await '3 hour ago'.asDateTime(logbox: fakeLogBox);
      expect(hourDate, isNotNull);
      expect(now.difference(hourDate!).inMinutes, inInclusiveRange(179, 181));

      final dayDate = await '2 day ago'.asDateTime(logbox: fakeLogBox);
      expect(dayDate, isNotNull);
      expect(now.difference(dayDate!).inHours, inInclusiveRange(47, 49));

      final weekDate = await '4 week ago'.asDateTime(logbox: fakeLogBox);
      expect(weekDate, isNotNull);
      expect(now.difference(weekDate!).inDays, inInclusiveRange(27, 29));

      final monthDate = await '2 month ago'.asDateTime(logbox: fakeLogBox);
      expect(monthDate, isNotNull);

      final yearDate = await '1 year ago'.asDateTime(logbox: fakeLogBox);
      expect(yearDate, isNotNull);
      expect(yearDate!.year, equals(now.year - 1));
    });

    test('asDateTime from cache returns cached value', () async {
      final mockFileInfo = MockFileInfo();
      final mockFile = MockFile();

      when(() => mockFileInfo.file).thenReturn(mockFile);
      when(
        () => mockFile.readAsString(encoding: any(named: 'encoding')),
      ).thenAnswer((_) async => '2023-11-01T10:00:00.000Z');

      when(
        () => mockCacheManager.getFileFromCache('Some Custom Date'),
      ).thenAnswer((_) async => mockFileInfo);

      final date = await 'Some Custom Date'.asDateTime(
        logbox: fakeLogBox,
        manager: mockCacheManager,
      );

      expect(date, isNotNull);
      expect(date!.year, equals(2023));
      expect(date.month, equals(11));

      verify(
        () => mockCacheManager.getFileFromCache('Some Custom Date'),
      ).called(1);
    });

    test('asDateTime saves to cache when parsed from custom format', () async {
      when(
        () => mockCacheManager.getFileFromCache(any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockCacheManager.putFile(any(), any(), key: any(named: 'key')),
      ).thenAnswer((_) async => MockFile());

      final date = await 'October 25 2023'.asDateTime(
        logbox: fakeLogBox,
        manager: mockCacheManager,
      );

      expect(date, isNotNull);
      verify(
        () => mockCacheManager.putFile(
          'October 25 2023',
          any(),
          key: 'October 25 2023',
        ),
      ).called(1);
    });

    test('asDateTime logs error when parsing fails', () async {
      final date = await 'invalid format'.asDateTime(logbox: fakeLogBox);

      expect(date, isNull);

      final captured = verify(
        () => mockStorage.add(log: captureAny(named: 'log')),
      ).captured;
      expect(captured.last, isA<LogEntryModel>());
      expect((captured.last as LogEntryModel).message, contains('Failed Parsing Date'));
    });
  });
}
