import 'package:core_analytics/core_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// A [FirebaseCrashlytics] whose every method throws, standing in for an
/// unavailable backend (e.g. a missing platform channel) so the reporter's
/// guards can be exercised in a VM test. It never touches the real
/// `FirebaseCrashlytics.instance` singleton.
class _ThrowingCrashlytics extends Mock implements FirebaseCrashlytics {}

final _backendDown = Exception('crashlytics backend down');

/// Builds the throwing fake with every backend method the reporter maps to
/// stubbed to throw synchronously.
_ThrowingCrashlytics _throwingBackend() {
  final backend = _ThrowingCrashlytics();
  when(
    () => backend.recordError(
      any(),
      any(),
      reason: any(named: 'reason'),
      fatal: any(named: 'fatal'),
    ),
  ).thenThrow(_backendDown);
  when(() => backend.log(any())).thenThrow(_backendDown);
  when(() => backend.setCustomKey(any(), any())).thenThrow(_backendDown);
  when(
    () => backend.setCrashlyticsCollectionEnabled(any()),
  ).thenThrow(_backendDown);
  return backend;
}

/// A real in-memory LogBox so guard logging runs without mocks.
LogBox _logBox() {
  return LogBox(storage: Storage(liveDataStorage: MemoryStorage()));
}

void main() {
  group('FirebaseCrashReporter', () {
    test('each method swallows backend errors and completes', () async {
      final backend = _throwingBackend();
      final logBox = _logBox();
      final reporter = FirebaseCrashReporter(backend, logBox: logBox);

      await reporter.reportFatal(Exception('boom'), StackTrace.empty);
      await reporter.reportNonFatal(Exception('oops'), StackTrace.empty);
      await reporter.logBreadcrumb('nav');
      await reporter.setKey('k', 'v');
      await reporter.setCollectionEnabled(false);

      // Every method reached the (throwing) backend, so the completions above
      // were not vacuous.
      verify(
        () => backend.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: true,
        ),
      ).called(1);
      verify(
        () => backend.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: false,
        ),
      ).called(1);
      verify(() => backend.log('nav')).called(1);
      verify(() => backend.setCustomKey('k', 'v')).called(1);
      verify(() => backend.setCrashlyticsCollectionEnabled(false)).called(1);

      // Each swallowed failure was logged to LogBox, not silently dropped.
      expect(logBox.storage.liveStorage.data, hasLength(5));
    });
  });
}
