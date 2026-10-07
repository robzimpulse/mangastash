import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every [CrashReporter] invocation into typed lists so tests can
/// assert exactly what the bridge forwarded, without touching Firebase.
class _RecordingCrashReporter implements CrashReporter {
  final List<({Object error, StackTrace stack, String? reason})> nonFatals = [];
  final List<({Object error, StackTrace stack, String? reason})> fatals = [];
  final List<String> breadcrumbs = [];
  final List<({String key, String value})> keys = [];

  @override
  Future<void> reportFatal(
    Object error,
    StackTrace stack, {
    String? reason,
  }) async {
    fatals.add((error: error, stack: stack, reason: reason));
  }

  @override
  Future<void> reportNonFatal(
    Object error,
    StackTrace stack, {
    String? reason,
  }) async {
    nonFatals.add((error: error, stack: stack, reason: reason));
  }

  @override
  Future<void> logBreadcrumb(String message) async {
    breadcrumbs.add(message);
  }

  @override
  Future<void> setKey(String key, String value) async {
    keys.add((key: key, value: value));
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}
}

void main() {
  group('LogBoxBridge', () {
    late LogBox logBox;
    late _RecordingCrashReporter reporter;

    setUp(() {
      logBox = LogBox(storage: Storage(liveDataStorage: MemoryStorage()));
      reporter = _RecordingCrashReporter();
    });

    tearDown(() {
      logBox.dispose();
    });

    Future<LogBoxBridge> startBridge({
      Map<String, String> contextKeys = const {},
    }) async {
      final bridge = LogBoxBridge(
        logBox: logBox,
        reporter: reporter,
        contextKeys: () async => contextKeys,
      );
      await bridge.start();
      return bridge;
    }

    test('error-level entry becomes exactly one reportNonFatal', () async {
      final bridge = await startBridge(
        contextKeys: {'appVersion': '1.2.3', 'appBuild': '42'},
      );

      logBox.log(
        'Chapter sync failed',
        name: 'Sync',
        error: StateError('bad state'),
        stackTrace: StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(reporter.nonFatals, hasLength(1));
      expect(reporter.fatals, isEmpty);
      expect(reporter.nonFatals.single.error.toString(), 'Bad state: bad state');
      expect(
        reporter.nonFatals.single.reason,
        contains('Chapter sync failed'),
      );
      expect(
        reporter.keys,
        containsAll([
          (key: 'appVersion', value: '1.2.3'),
          (key: 'appBuild', value: '42'),
        ]),
      );
      await bridge.close();
    });

    test('fatal-path entries are not double-reported', () async {
      final bridge = await startBridge();

      final error = StateError('fatal one');
      final stack = StackTrace.current;
      // What the fatal path in main.dart calls before logging the same error.
      bridge.markFatal(error, stack);
      logBox.log(
        'uncaught exception',
        name: 'FlutterError',
        error: error,
        stackTrace: stack,
      );
      await Future<void>.delayed(Duration.zero);

      expect(reporter.nonFatals, isEmpty);

      // A different error logged afterwards is still reported once.
      logBox.log(
        'other failure',
        name: 'Sync',
        error: StateError('other'),
        stackTrace: StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(reporter.nonFatals, hasLength(1));
      expect(reporter.nonFatals.single.error.toString(), 'Bad state: other');
      await bridge.close();
    });

    test('fatal with empty or absent stack dedupes like any other fatal',
        () async {
      final bridge = await startBridge();

      final error = StateError('isolate boom');
      // The isolate hook passes StackTrace.empty to markFatal AND logs it.
      bridge.markFatal(error, StackTrace.empty);
      logBox.log(
        'isolate boom',
        name: 'Isolate',
        error: error,
        stackTrace: StackTrace.empty,
      );
      // A hook variant logging a null stack while reporting StackTrace.empty
      // must dedupe too: absent and empty stacks are the same "no stack".
      logBox.log('isolate boom without trace', name: 'Isolate', error: error);
      await Future<void>.delayed(Duration.zero);

      expect(reporter.nonFatals, isEmpty);
      await bridge.close();
    });

    test('non-error entries become breadcrumbs, incognito still reports fully',
        () async {
      final bridge = await startBridge();

      logBox.log('hello', name: 'Info');
      logBox.log('opened reader', name: 'Navigation');
      await Future<void>.delayed(Duration.zero);

      expect(
        reporter.breadcrumbs,
        containsAll(['Info: hello', 'Navigation: opened reader']),
      );
      expect(reporter.nonFatals, isEmpty);

      logBox.log(
        'reader crashed while incognito',
        name: 'Reader',
        extra: {
          'incognito': true,
          'source': 'mangadex',
          'mangaId': 'm-1',
          'chapterId': 'c-9',
        },
        error: StateError('page failed'),
        stackTrace: StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(reporter.nonFatals, hasLength(1));
      expect(
        reporter.nonFatals.single.reason,
        contains('reader crashed while incognito'),
      );
      expect(
        reporter.keys,
        containsAll([
          (key: 'source', value: 'mangadex'),
          (key: 'mangaId', value: 'm-1'),
          (key: 'chapterId', value: 'c-9'),
        ]),
      );
      await bridge.close();
    });

    test('close() stops forwarding new entries', () async {
      final bridge = await startBridge();

      logBox.log('before', name: 'Info');
      await bridge.close();
      logBox.log(
        'after',
        name: 'Info',
        error: StateError('late'),
        stackTrace: StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(reporter.breadcrumbs, ['Info: before']);
      expect(reporter.nonFatals, isEmpty);
    });

    test('entries logged by the crash reporter itself are not fed back',
        () async {
      final bridge = await startBridge();

      // FirebaseCrashReporter's guard logs its own failures under this name;
      // forwarding them back would loop forever.
      logBox.log(
        'Failed to report non-fatal error via Firebase Crashlytics',
        name: 'FirebaseCrashReporter',
        error: StateError('backend down'),
        stackTrace: StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(reporter.nonFatals, isEmpty);
      expect(reporter.breadcrumbs, isEmpty);
      await bridge.close();
    });
  });
}
