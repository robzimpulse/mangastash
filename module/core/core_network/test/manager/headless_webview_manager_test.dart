import 'dart:async';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/src/manager/headless_webview_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeLogBox extends Mock implements LogBox {}

class FakeStorage extends Mock implements Storage {}

void main() {
  late FakeLogBox log;

  setUp(() {
    log = FakeLogBox();
    when(() => log.storage).thenReturn(FakeStorage());
  });

  group('handleResolvedImage', () {
    test('completes with error when args is empty', () {
      final completer = Completer<String>();

      handleResolvedImage(
        log,
        completer,
        args: [],
        url: 'https://example.com/image.png',
      );

      expect(completer.future, throwsA(isA<Exception>()));
    });

    test('completes with error when data is not a string', () {
      final completer = Completer<String>();

      handleResolvedImage(
        log,
        completer,
        args: [42],
        url: 'https://example.com/image.png',
      );

      expect(completer.future, throwsA(isA<Exception>()));
    });

    test('completes with error for unsupported extension', () {
      final completer = Completer<String>();

      handleResolvedImage(
        log,
        completer,
        args: ['data:image/tiff;base64,AAAA'],
        url: 'https://example.com/image.tiff',
      );

      expect(completer.future, throwsA(isA<Exception>()));
    });

    test('completes with error, does not throw, for empty data url', () async {
      final completer = Completer<String>();

      // '' splits to a length-1 list, so values[1] used to RangeError
      // inside the JS handler callback.
      handleResolvedImage(
        log,
        completer,
        args: [''],
        url: 'https://example.com/image.png',
      );

      await expectLater(completer.future, throwsA(isA<Exception>()));
    });

    test('completes with error, does not throw, for non-data url string',
        () async {
      final completer = Completer<String>();

      handleResolvedImage(
        log,
        completer,
        args: ['not-a-data-url'],
        url: 'https://example.com/image.png',
      );

      await expectLater(completer.future, throwsA(isA<Exception>()));
    });

    test('completes with the data url for supported extension', () {
      final completer = Completer<String>();
      const data = 'data:image/png;base64,AAAA';

      handleResolvedImage(
        log,
        completer,
        args: [data],
        url: 'https://example.com/image.png',
      );

      expect(completer.future, completion(data));
    });
  });

  group('handleRejectedImage', () {
    test('completes with error', () {
      final completer = Completer<String>();

      handleRejectedImage(
        log,
        completer,
        args: [Exception('boom')],
        url: 'https://example.com/image.png',
      );

      expect(completer.future, throwsA(isA<Exception>()));
    });
  });
}
